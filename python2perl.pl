#!/usr/bin/perl -w

#  python2perl.pl
#  Created by Mackenzie Baran on 27/09/2014.

$ifwhile=0;

while ($line = <>) {
    if ($line =~ /\s*if\s*(.*):\s*(.*)$/){
        #single line if statements ...subs2
        $cond = $1;
        $arg = $2;
        print "if \($cond\){\n\t";
        $line=$arg;
        $ifwhile=1;
    }elsif ($line =~ /\s*while\s*(.*):\s*(.*)$/){
        #single line if statements ...subs2
        $cond = $1;
        $arg = $2;
        print "if \($cond\){\n\t";
        $line=$arg;
        $ifwhile=1;
    }

    while ($line =~ /(.*);*/g){
        $line = $1;
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
            print "print ";
            
            while ($temp =~ m/\s*(\S*)\s*([\,\;\(\)\+\-\*\/]*)/g){
                $numvar = $1;
                $operation = $2;
                if ($numvar =~ m/[^\S][0-9]+\s*/){
                    print "$numvar $operation ";
                }elsif ($numvar =~ /[\"\"]+/){
                    print "\"$numvar \", ";
                }elsif ($numvar =~ /\s*[a-zA-Z0-9]+\s*/g){
                    print "\$$numvar $operation ";
                }
                
            }
            print ", \"\\n\";\n";
        } elsif ($line =~ /^\s*(.*)\s*=\s*(.*)/){
            #deal with $ variables ...subs 1
            $lhs=$1;
            $rhs = $2;
            if ($rhs =~ /(\s*\S*\s*[\(\)\+\-\*\/]\s*)+/){
                print "\$",$lhs,' = ';
                while ($rhs =~ m/(\s*(\S*)\s*[\+\-\*\/\%]*\s*)/g){
                    $temp1 = $1;
                    chomp $temp1;
                    $temp2 =$2;
                    if ($temp2 =~ /[^\s0-9]/){
                        print "\$";
                    }
                    print $temp1;
                }
                print ";\n";
            }else{
                print "\$$1= $2;\n";
            }
        } else {
            #Lines we can't translate are turned into comments
            print "#$line\n";
        }

        if ($ifwhile == 1){
            $ifwhile=0;
            print "\}\n";
        }
}
}