#!/usr/bin/perl -w

#  python2perl.pl
#  Created by Mackenzie Baran on 27/09/2014.

# initialise variables that will be used throughout code
$ifwhile=0;             # Gives the stage of compilation for if and while loops
$i=0;                   # Counter
$numLines=0;            # Count for number of lines
$sym="=!><";            # Variable that is used later for if and while loops

# push all lines ont an array/list
while ($element = <>) {
    push (@lines, $element);
    $numLines++;
}

# set line for first iteration
$line = $lines[0];

# main body of code
while ($i<$numLines){
    
    # match if and while statements
    # sets line equal to condition of statement
    # sets $ifwhile to 1 so later segments of code can function accordingly
    if ($line =~ /\s*if\s*(.*):\s*(.*)$/){
        $cond = $1;
        $arg = $2;
        print "if \(";
        $line=$cond;
        $sym="=!<>";
        $ifwhile=1;
    }elsif ($line =~ /\s*while\s*(.*):\s*(.*)$/){
        $cond = $1;
        $arg = $2;
        print "if \(";
        $line=$cond;
        $sym="=!<>";
        $ifwhile=1;
    }
    
    # translate #! line
    if ($i==0) {
        print "#!/usr/bin/perl -w\n";
    
    # Blank & comment lines can be passed unchanged
    } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
        print $line;

    # Python's print prints a new-line character by default
    # so we need to add it explicitly to the Perl print statement
    } elsif ($line =~ /^\s*print\s*"(.*)"\s*$/) {
        print "print \"$1\\n\";\n";
        
    # print statements with multiple terms (seperated by commas)
    } elsif ($line =~ /^\s*print\s*([^\"]*)/){
        $temp =$1;
        chomp $temp;
        print "print ";
        
        # each part of the code follows the pattern [number/variable] [symbol]
        # for each iteration of this pattern it is considered whether or not
        # the first item is a number or a variable and then treated accordingly
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
        
    # deal with reassignment of variable values
    # $sym must by adjusted so as to avoid getting a match when using bitwise operators
    } elsif ($line =~ /^\s*(.*)\s*([$sym]+)\s*(.*)/){
        $sym="=!";
        $lhs=$1;
        $operator=$2;
        $rhs = $3;
        if ($rhs =~ /(\s*\S*\s*[\(\)\+\-\*\/&~|<>^]*\s*)+/){
            print "\$",$lhs,"$operator ";
            while ($rhs =~ m/(\s*(\S*)\s*[\+\-\*\/\~%&|<>^]*\s*)/g){
                $temp1 = $1;
                chomp $temp1;
                $temp2 =$2;
                if ($temp2 =~ /[^\s0-9]/){
                    print "\$";
                }
                print $temp1;
            }
        }else{
            print "\$$1$2 $3";
        }
        
        if ($ifwhile!=1){
            print ";\n";
        }
    
    # break->last and next->continue
    }elsif ($line =~ /.*break.*/){
        print "last;\n";
    }elsif ($line =~ /.*continue.*/){
        print "next;\n";
        
    #Lines we can't translate are turned into comments
    } else {
        print "#$line\n";
    }

    # decide what to set $line to next
    # typically $line is set to the next element in the array,
    # however if $ifwhile != 0 $line is set differently
    if ($ifwhile == 1){
        $ifwhile=2;
        $argcount = 0;
        $k=0;
        print "\){\n\t";
        $line = $arg;
        
        # if there are multiple statements, push each statement on to an array
        # $ifwhile set to 3 so each element can be shifted off and interpreted individually
        if ($line =~ /(.*;)+(.*)/){
            $i++;
            $ifwhile = 3;
            $line = $1;
            $end=$2;
            while ($line =~ /([^;]*);/g){
                push(@iwargs,$1);
                $argcount++;
                $numLines++;
            }
            
            push (@iwargs,$end);
            $line = shift(@iwargs);
        }
        
    # once all statements have been processed
    # revert back to ordinary progression through the array
    }elsif ($ifwhile == 2){
        print "\}\n";
        $i++;
        $line = $lines[$i];
        $ifwhile=0;
        
    # shift through @iwargs and translate each statement
    }elsif ($ifwhile == 3){
        $k++;
        if ($k <= $argcount){
            $line = shift(@iwargs);
            print "\t";
        } else {
            $ifwhile=0;
            $line = $lines[$i];
            print "\}\n";
            $numLines=$numLines-$argcount;
        }
        
    # regularly progress through our array
    }else{
        $i++;
        $line = $lines[$i];
    }

}