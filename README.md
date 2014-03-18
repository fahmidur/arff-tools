## ARFF-Tools: Arff Helper Scripts

This is a small collection of support scripts for manipulating and converting Weka ARFF files.
These scripts are mostly designed for me and not intended for general public use. But it's here in case anyone finds them useful.

I apologize in advance for the lack of documentation. I'm working on it.
This is code put together in a rush with little attention to style.

### arff-to-fann-data.pl
Converts your arff file into a data file suitable for FANN. This script chooses every numeric to by the input vector excluding the attribute you choose to be the target class.

### arff-regex-instance-filter.pl
Allows you to filter your arff by whatever regex you want. You give it an input arff, a regex, and the name of
some attribute and it will generate two arffs, one for every matching instance and another for every non-matching instance.

### combine-arff.pl
Combine two compatible arff files into one. We keep the header of the first arff file. Small and simple.

### MLDataSet.rb
This little class is supposed to be for reading in an entire ARFF or FANN-Data file memory. And
it should let you easily read and write to and from both. Just wrote this up and at the moment it reads
from an ARFF, select features, and select random subsets of instances. More to come.
See example_usage_MLDataSet.rb