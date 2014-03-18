class MLDataSet
	require 'yaml'
	require 'json'

	DEBUG = true
	@@datasetCount = 0

	def initialize(loadpath=nil)
		@@datasetCount+=1
		@name = "DataSet_#{@@datasetCount}"

		@featureVectors = []
		@featureVectorNames = []
		@featureVectorTypes = []

		@featureNameToIndexMap = {}
		@inputFeatureVectorIndices = nil;
		@outputFeatureVectorIndices = nil;
		@fileBasename = nil

		if loadpath
			initializeFromFile(loadpath)
		else
			initializeEmpty();
		end
	end

	def name=(str)
		return unless str
		@name = str.gsub(/[^a-zA-Z0-9\.\-]+/, '_');
	end

	def name
		return @name
	end

	def to_s
		self.to_json
	end

	def to_json(*a)
		{:json_class => self.class.name, :data => hashSelf}.to_json(*a)
	end

	def hashSelf
		{
			:name => @name, 
			:featureVectorSize => @featureVectorTypes.size,
			:numFeatureVectors => @featureVectors.size,
			:featureVectorNames => @featureVectorNames,
			:featureVectorTypes => @featureVectorTypes,
			:featureVectors => @featureVectors,
			:inputFeatureVectorIndices => @inputFeatureVectorIndices,
			:outputFeatureVectorIndices => @outputFeatureVectorIndices
		}
	end

	def save(path)
		if File.directory?(path)
			path += "/#{@fileBasename || @name}.marsh"
		end
		File.open(path, 'w') { |f| f.write( Marshal.dump(self)) }
	end

	def self.load(path)
		return Marshal.load(File.read(path))
	end

	def saveArff(path)
		if File.directory?(path)
			path += "/#{@fileBasename || @name}.arff"
		end
		File.open(path, 'w') do |f|
			f.puts "@RELATION #{name}"
			@featureVectorNames.each_with_index do |name, i|
				f.puts "@ATTRIBUTE #{name} #{@featureVectorTypes[i]}"
			end
			f.puts "@DATA"
			@featureVectors.each do |vec|
				vec.map! {|e| e.inspect }
				f.puts vec.join(',')
			end
		end
	end

	def [](*featureNames)
		selectedFeatureIndices = featureNames.map{|e| @featureNameToIndexMap[e]}
		self.copy.selectByFeatureIndices!(selectedFeatureIndices)
	end

	def selectByFeatureIndices!(indices)
		unless indices.max < @featureVectorTypes.size && indices.min >= 0
			throw "selectByFeatureIndices: invalid indices"
		end
		@featureVectorTypes = @featureVectorTypes.values_at(*indices)
		@featureVectorNames = @featureVectorNames.values_at(*indices)
		@featureVectors.map! do |vec|
			vec.values_at(*indices)
		end
		assumeInputOutputIndices();
		return self
	end

	def random_instances!(num)
		unless num > 0 && num < @featureVectors.size
			throw "random_instances!: invalid num"
		end

		@featureVectors = @featureVectors.sample(num)
		return self
	end

	def copy
		@@datasetCount += 1
		Marshal.load(Marshal.dump(self))
	end

	protected

	def initializeFromFile(loadpath)
		unless File.exists?(loadpath)
			throw "File: #{loadpath} not found"
		end

		extname = File.extname(loadpath)
		@fileBasename = File.basename(loadpath, extname)

		case extname
		when ".arff"
			dputs "loading data from arff file..."
			loadFromArff(loadpath)
		when ".data"
			dputs "loading data from data file"
		else
			throw "extension: #{extname} unsupported"
		end
	end

	def loadFromArff(path)
		indata = false
		File.open(path, 'r').each_line do |line|
			line.chomp!
			next if line =~ /^\s*$/ || line =~ /^\s*\%/
			if line =~ /@data/i
				indata = true
				next
			end
			if indata
				vec = line.split(/\s*,\s*/)
				if vec.size != @featureVectorTypes.size
					throw "loadFromArff: vector size #{vec.size} != #{@featureVectorTypes.size}"
				end

				i = 0
				vec.map! do |value|
					if @featureVectorTypes[i] == "NUMERIC" || @featureVectorTypes[i] == "REAL"
						value = value.to_f
					end
					i+=1
					value
				end
				@featureVectors << vec;
			else
				if line =~ /@relation\s+(.+)$/i
					self.name = $1
				elsif line =~ /@attribute\s+(\S+)\s+(\S+)$/i
					@featureVectorNames << $1
					@featureVectorTypes << $2
				end
			end
		end

		
		assumeInputOutputIndices();

		unless indata
			throw "loadFromArff: no data section found"
		end
	end

	def assumeInputOutputIndices()
		# default assumptions
		@inputFeatureVectorIndices = (0...(@featureVectorTypes.size-1)).to_a
		@outputFeatureVectorIndices = ( (@featureVectorTypes.size-1)..(@featureVectorTypes.size-1) ).to_a

		@featureNameToIndexMap = {};
		@featureVectorNames.each_with_index do |name, i|
			throw "loadFromArff: duplicate feature name for #{name}" if @featureNameToIndexMap[name]
			@featureNameToIndexMap[name] = i
		end
	end


	# TODO
	def loadFromData(path)

	end

	# TODO
	def initializeEmpty()
		dputs "initializing from nothing"
	end

	#---FOR DEBUGING---
	def dputs(str)
		return unless DEBUG
		puts str
	end
	def dprint(str)
		return unless DEBUG
		print str
	end
end

