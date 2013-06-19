/**
 * tty.js
 * Adapted from
 * Copyright (c) 2012-2013, Christopher Jeffrey (MIT License)
 */

(function($) {

  'use strict';

  /**
   * Elements
   */

  var document = this.document,
    window = this,
    root;

  /**
   * Helpers
   */

  var EventEmitter = Terminal.EventEmitter,
    inherits = Terminal.inherits,
    on = Terminal.on,
    off = Terminal.off,
    cancel = Terminal.cancel;

  /**
   * tty
   */

  var tty = new EventEmitter();

  /**
   * Shared
   */

  tty.socket;
  tty.windows;
  tty.terms;
  tty.elements;

  /**
   * Open
   */

  tty.open = function(userID) {

    tty.socket = new Faye.Client(window.fayeServer);
    tty.windows = [];
    tty.terms = {};

    // register emit callbacks
    tty.socket.fayep = (function() {
      var callbackID = 0;
      return function(callback) {
        var name = 'callback_' + (callbackID++);
        window[name] = callback;
        return name;
      };
    }());

    tty.socket.fayec = function(reply) {
      reply = $.parseJSON(reply);
      var callback = window[reply.callback];
      if (callback) { callback(reply.error, reply.args); }
      delete window[reply.callback];
    };

    // wrapper for faye subscribe
    tty.socket.on = function(event, callback) {
      tty.socket.subscribe('/'+userID+'/' + event, callback);
    };

    // wrapper for faye publish
    tty.socket.emit = function() {
      var args  = $.makeArray(arguments);
      var event = args.shift();
      var data  = { args: args };
      // register callback if given
      if ($.isFunction(args.slice(-1)[0])) {
        var callback = args.pop();
        data.callback = tty.socket.fayep(callback);
      }
      tty.socket.publish('/'+userID+'/' + event, data);
    };

    tty.elements = {
      root: document.documentElement,
    };

    root = tty.elements.root;

    tty.socket.bind('transport:up', function() {
      tty.socket.on('callback', tty.socket.fayec);
    });

    tty.socket.on('data', function(msg) {
      if (!tty.terms[msg.id]) { return; }
      tty.terms[msg.id].write(msg.data);
    });

    tty.socket.on('kill', function(id) {
      if (!tty.terms[id]) { return; }
      tty.terms[id]._destroy();
    });

    // Keep windows maximized.
    on(window, 'resize', function() {
      var i = tty.windows.length,
        win;

      while (i--) {
        win = tty.windows[i];
        if (win.minimize) {
          win.minimize();
          win.maximize();
        }
      }
    });

    tty.emit('load');
    tty.emit('open');
  };

  /**
   * Reset
   */

  tty.reset = function() {
    var i = tty.windows.length;
    while (i--) {
      tty.windows[i].destroy();
    }

    tty.windows = [];
    tty.terms = {};

    tty.emit('reset');
  };

  /**
   * Window
   */

  function Window(el) {

    var self = this;
    EventEmitter.call(this);

    var bar, title;

    el.className = 'tty';

    bar = document.createElement('div');
    bar.className = 'bar';

    title = document.createElement('div');
    title.className = 'title';
    title.innerHTML = '';

    this.socket = tty.socket;
    this.element = el;
    this.bar = bar;
    this.title = title;

    this.tabs = [];
    this.focused = null;

    this.cols = Terminal.geometry[0];
    this.rows = Terminal.geometry[1];

    el.appendChild(bar);
    bar.appendChild(title);

    tty.windows.push(this);

    this.createTab();
    this.focus();
    this.bind();

    this.tabs[0].once('open', function() {
      tty.emit('open window', self);
      self.emit('open');
    });
  }

  inherits(Window, EventEmitter);

  Window.prototype.bind = function() {
    var self = this,
        el = this.element,
        bar = this.bar,
        last = 0;

    on(el, 'mousedown', function(ev) {

      // FIXME this is broken because the click always hits the tab div, which
      // is a child of the bar
      if (ev.target !== el && ev.target !== bar) { return; }

      self.focus();

      cancel(ev);

      if (new Date() - last < 600) {
        return self.maximize();
      }
      last = new Date();

      self.drag(ev);

      return cancel(ev);
    });
  };

  Window.prototype.focus = function() {
    // Focus Foreground Tab
    this.focused.focus();
    tty.emit('focus window', this);
    this.emit('focus');
  };

  Window.prototype.destroy = function() {
    if (this.destroyed) { return; }
    this.destroyed = true;

    if (this.minimize) { this.minimize(); }

    splice(tty.windows, this);
    if (tty.windows.length) { tty.windows[0].focus(); }

    this.element.parentNode.removeChild(this.element);

    this.each(function(term) {
      term.destroy();
    });

    tty.emit('close window', this);
    this.emit('close');
  };

  Window.prototype.drag = function(ev) {

    var self = this,
        el = this.element;

    if (this.minimize) { return; }

    var drag = {
      left: el.offsetLeft,
      top: el.offsetTop,
      pageX: ev.pageX,
      pageY: ev.pageY
    };

    el.style.opacity = '0.60';
    el.style.cursor = 'move';
    root.style.cursor = 'move';

    function move(ev) {
      el.style.left =
        (drag.left + ev.pageX - drag.pageX) + 'px';
      el.style.top =
        (drag.top + ev.pageY - drag.pageY) + 'px';
    }

    function up() {
      el.style.opacity = '';
      el.style.cursor = '';
      root.style.cursor = '';

      off(document, 'mousemove', move);
      off(document, 'mouseup', up);

      var ev = {
        left: el.style.left.replace(/\w+/g, ''),
        top: el.style.top.replace(/\w+/g, '')
      };

      tty.emit('drag window', self, ev);
      self.emit('drag', ev);
    }

    on(document, 'mousemove', move);
    on(document, 'mouseup', up);
  };

  Window.prototype.maximize = function() {
    if (this.minimize) { return this.minimize(); }

    var self = this,
        el = this.element,
        term = this.focused,
        x,
        y;

    var m = {
      cols: term.cols,
      rows: term.rows,
      left: el.offsetLeft,
      top: el.offsetTop,
      root: root.className
    };

    this.minimize = function() {
      delete this.minimize;

      el.style.left = m.left + 'px';
      el.style.top = m.top + 'px';
      el.style.width = '';
      el.style.height = '';
      term.element.style.width = '';
      term.element.style.height = '';
      el.style.boxSizing = '';
      root.className = m.root;

      self.resize(m.cols, m.rows);

      tty.emit('minimize window', self);
      self.emit('minimize');
    };

    window.scrollTo(0, 0);

    x = root.clientWidth / term.element.offsetWidth;
    y = root.clientHeight / term.element.offsetHeight;
    x = (x * term.cols) | 0;
    y = (y * term.rows) | 0;

    el.style.left = '0px';
    el.style.top = '0px';
    el.style.width = '100%';
    el.style.height = '100%';
    term.element.style.width = '100%';
    term.element.style.height = '100%';
    el.style.boxSizing = 'border-box';
    root.className = 'maximized';

    this.resize(x, y);

    tty.emit('maximize window', this);
    this.emit('maximize');
  };

  Window.prototype.resize = function(cols, rows) {
    this.cols = cols;
    this.rows = rows;

    this.each(function(term) {
      term.resize(cols, rows);
    });

    tty.emit('resize window', this, cols, rows);
    this.emit('resize', cols, rows);
  };

  Window.prototype.each = function(func) {
    var i = this.tabs.length;
    while (i--) {
      func(this.tabs[i], i);
    }
  };

  Window.prototype.createTab = function() {
    return new Tab(this, this.socket);
  };

  Window.prototype.highlight = function() {
    var self = this;

    this.element.style.borderColor = 'orange';
    setTimeout(function() {
      self.element.style.borderColor = '';
    }, 200);

    this.focus();
  };

  Window.prototype.focusTab = function(next) {
    var tabs = this.tabs,
        i = indexOf(tabs, this.focused),
        l = tabs.length;

    if (!next) {
      if (tabs[--i]) { return tabs[i].focus(); }
      if (tabs[--l]) { return tabs[l].focus(); }
    } else {
      if (tabs[++i]) { return tabs[i].focus(); }
      if (tabs[0])   { return tabs[0].focus(); }
    }

    return this.focused && this.focused.focus();
  };

  Window.prototype.nextTab = function() {
    return this.focusTab(true);
  };

  Window.prototype.previousTab = function() {
    return this.focusTab(false);
  };

  /**
   * Tab
   */

  function Tab(win, socket) {
    var self = this;

    var cols = win.cols,
        rows = win.rows;

    Terminal.call(this, cols, rows);

    var button = document.createElement('div');
    button.className = 'tab';
    button.innerHTML = '\u2022';
    win.bar.appendChild(button);

    on(button, 'click', function(ev) {
      if (ev.ctrlKey || ev.altKey || ev.metaKey || ev.shiftKey) {
        self.destroy();
      } else {
        self.focus();
      }
      return cancel(ev);
    });

    this.id = '';
    this.socket = socket || tty.socket;
    this.window = win;
    this.button = button;
    this.element = null;
    this.process = '';
    this.open();
    this.hookKeys();

    win.tabs.push(this);

  }

  inherits(Tab, Terminal);

  // Invoke this when the ID is assigned and the tab is ready to be opened.
  Tab.prototype.ready = function(id) {
    this.pty = id;
    this.id = id;
    tty.terms[this.id] = this;
    this.setProcessName('bash');
    tty.emit('open tab', this);
    this.emit('open');
  };

  // We could just hook in `tab.on('data', ...)`
  // in the constructor, but this is faster.
  Tab.prototype.handler = function(data) {
    this.socket.emit('input', this.id, data);
  };

  // We could just hook in `tab.on('title', ...)`
  // in the constructor, but this is faster.
  Tab.prototype.handleTitle = function(title) {
    if (!title) { return; }

    title = sanitize(title);
    this.title = title;

    if (this.window.focused === this) {
      this.window.bar.title = title;
    }
  };

  Tab.prototype._write = Tab.prototype.write;

  Tab.prototype.write = function(data) {
    if (this.window.focused !== this) { this.button.style.color = 'red'; }
    return this._write(data);
  };

  Tab.prototype._focus = Tab.prototype.focus;

  Tab.prototype.focus = function() {
    if (Terminal.focus === this) { return; }

    var win = this.window;

    // maybe move to Tab.prototype.switch
    if (win.focused !== this) {
      if (win.focused) {
        if (win.focused.element.parentNode) {
          win.focused.element.parentNode.removeChild(win.focused.element);
        }
        win.focused.button.style.fontWeight = '';
      }

      win.element.appendChild(this.element);
      win.focused = this;

      win.title.innerHTML = this.process;
      this.button.style.fontWeight = 'bold';
      this.button.style.color = '';
    }

    this.handleTitle(this.title);

    this._focus();

    win.focus();

    tty.emit('focus tab', this);
    this.emit('focus');
  };

  Tab.prototype._resize = Tab.prototype.resize;

  Tab.prototype.resize = function(cols, rows) {
    this.socket.emit('resize', this.id, cols, rows);
    this._resize(cols, rows);
    tty.emit('resize tab', this, cols, rows);
    this.emit('resize', cols, rows);
  };

  Tab.prototype.__destroy = Tab.prototype.destroy;

  Tab.prototype._destroy = function() {
    if (this.destroyed) { return; }
    this.destroyed = true;

    var win = this.window;

    this.button.parentNode.removeChild(this.button);
    if (this.element.parentNode) {
      this.element.parentNode.removeChild(this.element);
    }

    if (tty.terms[this.id]) { delete tty.terms[this.id]; }
    splice(win.tabs, this);

    if (win.focused === this) {
      win.previousTab();
    }

    if (!win.tabs.length) {
      win.destroy();
    }

    this.__destroy();
  };

  Tab.prototype.destroy = function() {
    if (this.destroyed) { return; }
    this.socket.emit('kill', this.id);
    this._destroy();
    tty.emit('close tab', this);
    this.emit('close');
  };

  Tab.prototype.hookKeys = function() {
    this.on('key', function(key) {
      // ^A for screen-key-like prefix.
      if (Terminal.screenKeys) {
        if (this.pendingKey) {
          this._ignoreNext();
          this.pendingKey = false;
          this.specialKeyHandler(key);
          return;
        }

        // ^A
        if (key === '\x01') {
          this._ignoreNext();
          this.pendingKey = true;
          return;
        }
      }

      // Alt-` to quickly swap between windows.
      if (key === '\x1b`') {
        var i = indexOf(tty.windows, this.window) + 1;

        this._ignoreNext();
        if (tty.windows[i]) { return tty.windows[i].highlight(); }
        if (tty.windows[0]) { return tty.windows[0].highlight(); }

        return this.window.highlight();
      }

      // URXVT Keys for tab navigation and creation.
      // Shift-Left, Shift-Right, Shift-Down
      if (key === '\x1b[1;2D') {
        this._ignoreNext();
        return this.window.previousTab();
      } else if (key === '\x1b[1;2B') {
        this._ignoreNext();
        return this.window.nextTab();
      } else if (key === '\x1b[1;2C') {
        this._ignoreNext();
        return this.window.createTab();
      }

      if (key === Terminal.escapeKey) {
        this._ignoreNext();
        return setTimeout(function() {
          this.keyDown({ keyCode: 27 });
        }.bind(this), 1);
      }
    });
  };

  //var keyDown = Tab.prototype.keyDown;
  //Tab.prototype.keyDown = function(ev) {
  //  if (!Terminal.escapeKey) {
  //    return keyDown.apply(this, arguments);
  //  }
  //  if (ev.keyCode === Terminal.escapeKey) {
  //    return keyDown.call(this, { keyCode: 27 });
  //  }
  //  return keyDown.apply(this, arguments);
  //};

  // tmux/screen-like keys
  Tab.prototype.specialKeyHandler = function(key) {
    var win = this.window;

    switch (key) {
    case '\x01': // ^A
      this.send(key);
      break;
    case 'c':
      win.createTab();
      break;
    case 'k':
      win.focused.destroy();
      break;
    case 'w': // tmux
    case '"': // screen
      break;
    default:
      if (key >= '0' && key <= '9') {
        key = +key;
        // 1-indexed
        key--;
        if (!~key) { key = 9; }
        if (win.tabs[key]) {
          win.tabs[key].focus();
        }
      }
      break;
    }
  };

  Tab.prototype._ignoreNext = function() {
    // Don't send the next key.
    var handler = this.handler;
    this.handler = function() {
      this.handler = handler;
    };
    var showCursor = this.showCursor;
    this.showCursor = function() {
      this.showCursor = showCursor;
    };
  };

  /**
   * Program-specific Features
   */

  Tab.scrollable = {
    irssi: true,
    man: true,
    less: true,
    htop: true,
    top: true,
    w3m: true,
    lynx: true,
    mocp: true,
    vim: true
  };

  Tab.prototype._bindMouse = Tab.prototype.bindMouse;

  Tab.prototype.bindMouse = function() {
    if (!Terminal.programFeatures) { return this._bindMouse(); }

    var self = this;

    var wheelEvent = ('onmousewheel' in window) ? 'mousewheel' : 'DOMMouseScroll';

    on(self.element, wheelEvent, function(ev) {
      if (self.mouseEvents) { return; }
      if (!Tab.scrollable[self.process]) { return; }
      if ((ev.type === 'mousewheel' && ev.wheelDeltaY > 0) || (ev.type === 'DOMMouseScroll' && ev.detail < 0)) {
        // page up
        self.keyDown({keyCode: 33});
      } else {
        // page down
        self.keyDown({keyCode: 34});
      }
      return cancel(ev);
    });

    return this._bindMouse();
  };

  Tab.prototype.setProcessName = function(name) {
    name = sanitize(name);

    if (this.process !== name) {
      this.emit('process', name);
    }

    this.process = name;
    this.button.title = name;

    if (this.window.focused === this) {
      // if (this.title) {
      //   name += ' (' + this.title + ')';
      // }
      this.window.title.innerHTML = name;
    }
  };

  /**
   * Helpers
   */

  function indexOf(obj, el) {
    var i = obj.length;
    while (i--) {
      if (obj[i] === el) { return i; }
    }
    return -1;
  }

  function splice(obj, el) {
    var i = indexOf(obj, el);
    if (~i) { obj.splice(i, 1); }
  }

  function sanitize(text) {
    if (!text) { return ''; }
    return (text + '').replace(/[&<>]/g, '');
  }

  /**
   * Expose
   */

  tty.Window = Window;
  tty.Tab = Tab;
  tty.Terminal = Terminal;

  this.tty = tty;

  /**
   * Configuration
   */
  Terminal.programFeatures = true;

}).call(window, jQuery);
