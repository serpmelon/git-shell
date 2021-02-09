#! /usr/bin/perl

$CACHE = cacheFile();
%paramMap = paramHandler(@ARGV);
@subKeys = keys %paramMap;
@subValues = values %paramMap;

foreach (@subKeys) {
	
	my $key = $_;
	my $value = $paramMap{$key};
	my $method = subMaker($key);
  $method -> ($value);
}
# show the branc list which matches the pattern read
sub branch{
	
	$pattern = $_[0];
	$cmd = "git branch --list -a '*$pattern*'";
	$result = `$cmd`;
	@arr = split /\n/, $result;
	open(DATA, "+>$CACHE") or die "文件无法打开, $!";

	$index = 0;
	foreach $item(@arr){
  	print "$index: $item \n";
		print DATA "$item \n";
		$index++;
	}

}

# checkout the selected branch 
sub checkout{

	my $line = $_[0];	
	open(DATA, "<$CACHE") or die "文件无法打开, $!";
	my @lines = <DATA>;
	my $branch = @lines[$line];
	my $userName = $_[1];
	my $b = "";
	my $remote = "remotes";
	if($branch =~ /$remote/){
		$b = "-b";
	}
	# delete the "remotes" word before branch
	$branch =~ s/^\W+$remote\///;
	# delete special operator \n \r \s;
	$branch =~ s/[\n\r\s]//g;
	my $remote = "";

	if($userName) {
		$remote = $branch;
		$branch =~ s/^.*feature\/.*\//feature\//;
		$branch = $branch . "_$userName";
	}
	my $check = "git checkout $b $branch $remote";
	system($check);
}

# function maker
sub subMaker{
	
	my $mode = $_[0];
	my $newSub = sub {
	  my $p1 = $_[0];
		if("b" eq $mode) {
			return branch($p1);
		}
		elsif("c" eq $mode) {
			return checkout($p1);
		}
		elsif("C" eq $mode) {
			return checkout($p1, userName());
		}
	};

	return $newSub;
}

# param handler, return mode hash, key is mode, value is parameter 
sub paramHandler{
	
	# the chosen mode, like -b, -c or -bc
	my @paramArray = @_;
	my $p1 = @paramArray[0];
	my @mode = split //, $p1;
	my $line = @mode[0];

	if($line ne "-"){ 
		die "illegal !";
	}

	my %paramMap = ();
	my $i = 1;
	foreach (1..$#mode) {
		$paramMap{@mode[$_]} = @paramArray[$i];
		$i++;
	}

	return %paramMap;
}

# get user name
sub userName{

	my $userKey = "USER";
	my $userName = $ENV{$userKey};

	if(!$userName) {
		$userName = "perl";
	}

	return $userName;
}

# get home directory
sub cacheFile{
	my $d = $0;

	$d =~ s/\n\t\s//;
	# delete the file name
	$d =~ s/\/\w+$/\//;
  my $file = $d ."gitt-config/cache";
	# create file if not exists
	unless(-e $file) {
		createFile($file);
	}

	return $file;
}

# create file recursively
sub createFile{
	my $file = $_[0];
	my @path = split /\//, $file;
	my $max = $#path;
	foreach (0..$max) {
		my $f = join "\/", @path[0..$_];
		unless(-e $f){
			if($_ < $max) {
				mkdir $f;
			} 
			else {
				open my $d, ">$f";
				close $f;
			}
		}
	}
}




