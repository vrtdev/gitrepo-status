require 'gitrepo/status/version'
require 'rugged'
require 'awesome_print'
require 'pp'

# Class Gitrepo
class Gitrepo
  # Class Gitrepo::Status
  class Status
    def initialize(opt = {})
      @path = opt.fetch(:path)
      repo
    end

    def repo
      return @repo if @repo
      @repo = Rugged::Repository.discover(@path)
      @basepath = repo.path.chomp('/.git/')
      @repo
    end

    # def remotes
    #   repo.remotes
    # end

    def fetch
      # libgit2 and https... a dificult story... :-(
      # remotes.each do |remote|
      #   repo.fetch remote.name
      # end
      cmd1 = 'git branch -r | grep -v "\->" | while read remote; do git branch --track "${remote#origin/}" "$remote" 2> /dev/null; done'
      cmd2 = 'git fetch --all'
      Dir.chdir(@path) do
        `#{cmd1}`
        `#{cmd2}`
      end
    end

    def puppet_module?
      !repo.index.get('metadata.json').nil?
    end

    def ahead_behind
      branches_txt = ''
      branches = {}
      Dir.chdir(@path) do
        branches_txt = `git branch --contains HEAD | grep -v 'detached at'`
      end
      branches_txt.split("\n").each do |branch|
        branch.strip!
        branches[branch] = repo.ahead_behind(repo.head.target_id, branch)
      end
      branches
    end

    def test
      # puts '--- repo.methods ---'
      # ap repo.methods
      puts '--- repo.path ---'
      ap repo.path

      ap repo.index.get('metadata.json')

      puts '--- repo.last_commit ---'
      ap repo.last_commit.tree_id

      puts "Is Puppet Module? (has '/metadata.json'?) : #{puppet_module?}"
      head = repo.head
      puts '--- repo.head ---'
      ap head

      # sha1 hash of the newest commit
      head_sha = head.target_id
      puts '--- repo.head.target_id ---'
      ap head_sha

      ap repo.ahead_behind(head_sha, 'origin/master')

      puts '--- repo remotes ---'
      repo.remotes.each do |remote|
        # ap remote.methods
        ap remote.url
      end

      puts '--- repo branch ---'
      repo.branches.each do |branch|
        # ap branch.methods
        ap branch.name
        ap branch.head?
        ap branch.upstream
      end

      # # the commit message associated the newest commit
      # commit = repo.lookup(head_sha)
      # puts '--- repo.lookup(repo.head.target_id) ---'
      # pp commit
      #
      # puts '--- repo object methods ---'
      # ap repo.methods
      #
      puts '--- repo remotes ---'
      repo.remotes.each do |remote|
        # ap remote.methods
        ap remote.name
        ap remote.url
      end
      #
      # puts '--- repo branch ---'
      # repo.branches.each do |branch|
      #   ap branch.methods
      #   ap branch.name
      # end
    end
  end
end
