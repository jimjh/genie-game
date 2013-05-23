# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe WeakComparator do

  let(:comparator) { WeakComparator }

  def random_string
    (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
  end

  def random_integer
    Random.rand(10**8)
  end

  def random_float
    Random.rand
  end

  context 'given two simple strings that are the same' do
    let(:left)  { random_string }
    let(:right) { left.clone }
    it { should be_same(left, right) }
  end

  context 'given two simple strings that are different' do
    it { should_not be_same(random_string, random_string) }
  end

  context 'given two simple integers that are the same' do
    let(:n) { random_integer }
    it { should be_same(n.to_s, n) }
    it { should be_same(n, n) }
  end

  context 'given invalid string for integer answer' do
    let(:right) { random_integer }
    let(:left)  { 'abc' }
    it { should_not be_same(left, right) }
  end

  context 'given two simple integers that are different' do
    let(:left)  { random_integer }
    let(:right) { random_integer }
    it { should_not be_same(left.to_s, right) }
    it { should_not be_same(left, right) }
  end

  context 'given two simple floats that are the same' do
    let(:n) { random_float }
    it { should be_same(n, n) }
    it { should be_same(n.to_s, n) }
  end

  context 'given two simple floats that are different' do
    let(:left)  { random_float }
    let(:right) { random_float }
    it { should_not be_same(left, right) }
    it { should_not be_same(left.to_s, right) }
  end

  context 'given two numbers that are numerically equivalent' do
    let(:n) { random_integer }
    it { should be_same(n.to_f, n) }
    it { should be_same(n.to_f.to_s, n) }
    it { should be_same(n.to_f.to_s + '000', n) }
    it { should be_same(n.to_s + 'e0', n) }
    it { should be_same(n.to_s, n) }
    it { should be_same(n.to_f.to_s, n.to_f) }
    it { should be_same(n.to_s + 'e0', n.to_f) }
    it { should be_same(n.to_s, n.to_f) }
  end

  context 'given a numeric answer' do
    let(:ans) { 42.0 }
    it { should_not be_same('x', ans) }
    it { should_not be_same('true', ans) }
    it { should_not be_same('{', ans) }
    it { should_not be_same('[42]', ans) }
  end

  context 'given two booleans that are the same' do
    it { should be_same('true', true) }
    it { should be_same('T', true) }
    it { should be_same('false', false) }
    it { should be_same('F', false) }
  end

  context 'given two booleans that are different' do
    it { should_not be_same('false', true) }
    it { should_not be_same('F', true) }
    it { should_not be_same('true', false) }
    it { should_not be_same('T', false) }
  end

  it 'accepts hashes that are the same' do
    comparator
      .same?({'X' => 'a', 'Y' => '42', 'Z' => 't'},
             {'X' => 'a', 'Y' =>  42.0, 'Z' => true})
      .should eql('X' => true, 'Y' => true, 'Z' => true)
  end

  it 'rejects hashes that have different sizes' do
    comparator
      .same?({'X' => 'a', 'Y' => 'b'},
            {X: 'a', Y: 'b', Z: 'c'})
      .should be_false
  end

  it 'rejects hashes that have different elements' do
    comparator
      .same?({'X' => 'a', 'Y' => '42', 'Z' => 't'},
             {'X' => 'a', 'Y' =>  16,  'Z' =>  true})
      .should eql('X' => true, 'Y' => false, 'Z' => true)
  end

end
