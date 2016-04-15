#!/usr/bin/env ruby

require "test/unit"

$version = ARGV[0]
if not $version
  puts 'Should provide version! i.e: .../thefuck_test.rb 3.5.9'
  exit!
end


class ThefuckTest < Test::Unit::TestCase


  def test_simple1
    bin = "/usr/local/bin"
    IO.popen("#{bin}/thefuck --version 2>&1", "r") do |pipe|
      assert_match /The Fuck #{$version} using Python [0-9\.]+/, pipe.read.chomp
      pipe.close
    end
  end

  def test_simple2
    bin = "/usr/local/bin"
    IO.popen("#{bin}/thefuck --alias", "r") do |pipe|
      assert_match /.+TF_ALIAS.+thefuck.+/, pipe.read.chomp
      pipe.close
    end
  end

  def test_simple3
    bin = "/usr/local/bin"
    IO.popen("THEFUCK_REQUIRE_CONFIRMATION=false #{bin}/thefuck git branchh 2>&1", "r+") do |pipe|
      pipe.puts "\n"
      pipe.close_write
      assert_match /git branch.+/, pipe.read.chomp
      pipe.close
    end
  end

  def test_simple4
    bin = "/usr/local/bin"
    IO.popen("THEFUCK_REQUIRE_CONFIRMATION=false #{bin}/thefuck echho ok 2>&1", "r+") do |pipe|
      pipe.puts "\n"
      pipe.close_write
      assert_match /echo ok.+/, pipe.read.chomp
      pipe.close
    end
  end

  def test_simple5
    bin = "/usr/local/bin"
    IO.popen("THEFUCK_REQUIRE_CONFIRMATION=false #{bin}/thefuck git brnch 2>&1", "r+") do |pipe|
      pipe.puts "\n"
      pipe.close_write
      assert_match /git branch.+/, pipe.read.chomp
      pipe.close
    end
  end

  def test_simple6
    bin = "/usr/local/bin"
    IO.popen("#{bin}/fuck", "r+") do |pipe|
      assert_match /^Seems like .+fuck.+ alias isn't configured.+/, pipe.read.chomp
      pipe.close
    end
  end

end
