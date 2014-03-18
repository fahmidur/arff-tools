require './MLDataSet.rb'
#---example usage
datasetFromArff = MLDataSet.new('sample_datasets/iris.arff')

##not yet implemented
# datasetFromFann = MLDataSet.new('sample_datasets/fname.data')
# datasetEmpty = MLDataSet.new
# datasetEmpty.name = "testing this thing 1 2-3"

##example usage
# we can make selections across features
# by giving in a list of featureNames
# puts datasetFromArff['sepalwidth', 'class'].random_instances!(5).save('sample_outputs')

# this is non-destructive
# puts datasetFromArff

# puts "\n====================================\n".green
# only5Instances = MLDataSet.load('sample_outputs/iris.marsh')
# puts only5Instances
# only5Instances.saveArff('sample_outputs')

datasetFromArff_r1 = datasetFromArff.random_instances!(5)
datasetFromArff_r1.saveArff('sample_outputs/iris_random_1.arff')


# puts "datasetFromFann = \n#{datasetFromFann}"
# puts "datasetEmpty = \n#{datasetEmpty}"