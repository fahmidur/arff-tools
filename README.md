## ARFF-Tools: Arff Helper Scripts

This is a small collection of support scripts for manipulating and converting Weka ARFF files.
These scripts are mostly designed for me and not intended for general public use. But it's here in case anyone finds them useful.

I apologize in advance for the lack of documentation. I'm working on it.
This is code put together in rush with little attention to style.

### arff-to-fann-data.pl
converts your arff file into a data file suitable for FANN. This script chooses every numeric to by the input vector excluding the attribute you choose to be the target class.


