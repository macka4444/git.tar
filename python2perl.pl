#!/usr/bin/perl -w

#  python2perl.pl
#  Created by Mackenzie Baran on 27/09/2014.

while ($line = <>) {
    if ($line =~ /^#!/ && $. == 1) {
        # translate #! line... subs 0
        print "#!/usr/bin/perl -w\n";
    
    } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
        # Blank & comment lines can be passed unchanged... subs 0
        print $line;

    } elsif ($line =~ /^\s*print\s*"(.*)"\s*$/) {
        # Python's print print a new-line character by default
        # so we need to add it explicitly to the Perl print statement
        # ... subs 0
        print "print \"$1\\n\";\n";
        
    } elsif ($line =~ /^\s*print\s*([^\"]*)/){
        # printing variables ... subs 1
        $temp =$1;
        chomp $temp;
        if ($temp =~ /(\s*\S*\s*[\(\)\+\-\*\/]\s*)+/){
            print "print ";
            while ($temp =~ /(\s*\S*\s*[\(\)\+\-\*\/]*\s*)/g){
                print "$1";
            }
            print ", \"\\n\";\n";
        }else{
            print "print \"\$",($temp),"\\n\";\n";
        }
    } elsif ($line =~ /^\s*(.*)\s*=\s*(.*)/){
        #deal with $ variables ...subs 1
        $lhs=$1;
        $rhs = $2;
        if ($rhs =~ /(\s*[^a-zA-Z][0-9]+\s*[\+\-\*\/\%]*)+/){
            print "\$$lhs= $rhs;\n";
        }elsif ($rhs =~ /(\s*\S*\s*[\(\)\+\-\*\/]\s*)+/){
            print "\$",$lhs,' = ';
            while ($rhs =~ m/(\s*\S*\s*[\+\-\*\/\%]*\s*)/g){
                $temp = $1;
                chomp $temp;
                if ($temp =~ /[^\s]/){
                    print "\$";
                }
                print $temp;
            }
            print ";\n";
        }else{
            print "\$$1= $2;\n";
        }
        
    } else {
        #Lines we can't translate are turned into comments
        print "#$line\n";
        
    }
}