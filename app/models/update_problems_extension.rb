module UpdateProblemsExtension

  def update_or_initialize(new_problems = [])

    new_problems.map!.with_index { |p, i| p[:position] = i; p }
    new_enum = new_problems.sort_by { |p| p[:digest] }.each
    old_enum = proxy_association.owner.problems.each

    def grab_next(enum); enum.next rescue :EOF; end
    new = grab_next new_enum
    old = grab_next old_enum

    loop do
      case
      when :EOF == new && :EOF == old
        break
      when :EOF == old || (:EOF != new and new[:digest] < old.digest)
        proxy_association.owner.problems.build new
        new = grab_next new_enum
      when :EOF == new || (:EOF != old and new[:digest] > old.digest)
        old.active = false
        old = grab_next old_enum
      else
        old.position = new[:position]
        new = grab_next new_enum
        old = grab_next old_enum
      end

    end
  end

end
