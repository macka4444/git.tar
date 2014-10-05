#!/usr/bin/perl -w

#  python2perl.pl
#  Created by Mackenzie Baran on 27/09/2014.

$ifwhile=0;
$i=0;
$j=0;
$extension=0;
my @lines;
$sym="=!><";

#push all lines ont an array/list

while ($element = <>) {
    push (@lines, $element);
    $j++;
}
$line = $lines[0];

while ($i-$extension<$j){
    #print "...$ifwhile\n";
    #sprint "<--";
    
    if ($line =~ /\s*if\s*(.*):\s*(.*)$/){
        #single line if statements ...subs2
        $cond = $1;
        $arg = $2;
        print "if \(";
        $line=$cond;
        $sym="=!<>";
        $ifwhile=1;
    }elsif ($line =~ /\s*while\s*(.*):\s*(.*)$/){
        #single line if statements ...subs2
        $cond = $1;
        $arg = $2;
        print "if \(";
        $line=$cond;
        $sym="=!<>";
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
    } elsif ($line =~ /^\s*(.*)\s*([$sym]+)\s*(.*)/){
        #deal with $ variables ...subs 1
        $sym="=!";
        $lhs=$1;
        $operator=$2;
        #print "-->$operator\n";
        $rhs = $3;
        if ($rhs =~ /(\s*\S*\s*[\(\)\+\-\*\/&~|<>^]*\s*)+/){
            print "\$",$lhs,"$operator ";
            while ($rhs =~ m/(\s*(\S*)\s*[\+\-\*\/\~%&|<>^]*\s*)/g){
                $temp1 = $1;
                chomp $temp1;
                $temp2 =$2;
                #print "\n-->$temp1\n";
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
    }elsif ($line =~ /.*break.*/){
        print "last;\n";
    }elsif ($line =~ /.*continue.*/){
        print "next;\n";
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
                # print "-$1-\n";
                push(@iwargs,$1);
                $argcount++;
                $extension++;
            }
            
            push (@iwargs,$end);
            #print "----@iwargs....";
            $line = shift(@iwargs);
        }
    }elsif ($ifwhile == 2){
        print "\}\n";
        $i++;
        $line = $lines[$i];
        $ifwhile=0;
    }elsif ($ifwhile == 3){
        $k++;
        #print "----";
        if ($k <= $argcount){
            $line = shift(@iwargs);
            print "\t";
        } else {
            $ifwhile=0;
            #$i++;
            $line = $lines[$i];
            print "\}\n";
            $extension=$extension-$argcount;
        }
    }else{
        $i++;
        $line = $lines[$i];
    }

}