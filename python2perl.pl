#!/usr/bin/perl -w

#  python2perl.pl
#  Created by Mackenzie Baran on 27/09/2014.

$ifwhile=0;
$i=0;
$j=0;
$extension=0;
my @lines;

#push all lines ont an array/list

while ($element = <>) {
    push (@lines, $element);
    $j++;
}
$line = $lines[0];

while ($i-$extension<$j){
    if ($line =~ /\s*if\s*(.*):\s*(.*)$/){
        #single line if statements ...subs2
        $cond = $1;
        $arg = $2;
        print "if \(";
        $line=$cond;
        $ifwhile=1;
    }elsif ($line =~ /\s*while\s*(.*):\s*(.*)$/){
        #single line if statements ...subs2
        $cond = $1;
        $arg = $2;
        print "if \(";
        $line=$cond;
        $ifwhile=1;
    }
    
    
    
    if ($i==0) {
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
        print ", \"\\n\"";
        if ($ifwhile!=1){
            print ";\n";
        }
    } elsif ($line =~ /^\s*(.*)\s*([=><!]+)\s*(.*)/){
        #deal with $ variables ...subs 1
        $lhs=$1;
        $operator=$2;
        $rhs = $3;
        if ($rhs =~ /(\s*\S*\s*[\(\)\+\-\*\/]\s*)+/){
            print "\$",$lhs,"$operator ";
            while ($rhs =~ m/(\s*(\S*)\s*[\+\-\*\/\%]*\s*)/g){
                $temp1 = $1;
                chomp $temp1;
                $temp2 =$2;
                if ($temp2 =~ /[^\s0-9]/){
                    print "\$";
                }
                print $temp1;
            }
            #    print ";\n";
        }else{
            print "\$$1$2 $3";
        }
        if ($ifwhile!=1){
            print ";\n";
        }
    } else {
        #Lines we can't translate are turned into comments
        print "#$line\n";
    }

    if ($ifwhile == 1){
        $ifwhile=2;
        
        $argcount = 0;
        $k=0;
        print "\){\n\t";
        $line = $arg;
        if ($line =~ /(.*;)+(.*)/){
            $i++;
            $ifwhile = 3;
            $line = $1;
            $end=$2;
            #print $line, "...\n";
            while ($line =~ /([^;]*);/g){
                #print "-$1-\n";
                push(@iwargs,$1);
                $argcount++;
                $extension++;
            }
            push (@iwargs,$end);
            $line = shift(@iwargs);
        }
    }elsif ($ifwhile == 2){
        print "\}\n";
        $i++;
        $line = $lines[$i];
        $ifwhile=0;
    }elsif ($ifwhile == 3){
        $k++;
        if ($k != $argcount){
            $ifwhile=0;
            $i++;
            $line = $lines[$i];
            print "\}\n";
        } else {
            $line = shift(@iwargs);
            print "\t";
        }
    }else{
        $i++;
        $line = $lines[$i];
    }

}
#print "\n>\n$line\n<\n";