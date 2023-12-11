#
# Extract all commits by git rest --hard
#  and separately copies each commit to the directory "../_"
#
use File::Path;
use strict;

my $scriptname = $0;
#chdir 'xtextxtend-book-examples';

my $logName = 'git_info.log';
my $place = '../_/';
my %commits;

@_ = system("git log > $logName");

open(IN, "<$logName") or die "Fail open $logName\n$!\n";
while(<IN>) {
	chomp; s/\s+$//s;
	if( /commit\s+(\w{40})/ ) {
		my $id = substr($1,0,7);
		<IN>;<IN>;<IN>;$_=<IN>; chomp; s/\s+$//s;
		#s/^\s*?changes:\s*?//;
		s/^\s+//;
#		print "$id - $_\n";
		$commits{$id}=$_;
	}
}
close(IN);

for my $id (keys %commits) {
	my $dirname = $commits{$id};
	print "$dirname\n";
	`git reset --hard $id`;
	my $dst = $place.$dirname;
	mkdir $dst;
	`cp -r * "$dst"`;
	`cp -r .* "$dst"`;
	rmtree("$dst/.git");
	unlink "$dst/$scriptname";
	unlink "$dst/$logName";
}