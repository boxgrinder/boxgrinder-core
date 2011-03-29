require 'rubygems'#TODO hack to get tests running initially...
require 'kwalify'
require 'boxgrinder-core/schemas/appliance-transformers'
require 'boxgrinder-core/validators/appliance-parser-helper'
require 'boxgrinder-core/helpers/log-helper'
require 'boxgrinder-core/validators/errors'

module BoxGrinder
  class ApplianceParserValidator
    attr_reader :schemas
    attr_reader :specifications
    attr_reader :messages

    @@messages = {
        :pattern_unmatch => "'%s': not a valid pattern for '%s'"
    }

    def initialize(schema_files=[], options={})
      @log = options[:log] || Logger.new(STDOUT)
      @schemas = {}
      load_schema_files(*schema_files) unless schema_files.empty?
      @specifications = {}
    end

    def load_schema( schema_name, schema_content )
      @schemas[schema_name]=validate_schema(schema_name,schema_content)
    end

    def load_schema_files( *schema_paths )
      parse_paths(schema_paths) do |name, data|
        @schemas[name]=validate_schema(name,data)
      end
    end

    def load_specification( specification_content )
      document=validate_specification("yaml-string",specification_content)
      @specifications[document["name"]]=document
    end
    #Return last item for convenience TODO return array in future?
    def load_specification_files( *specification_paths )
      document=nil
      parse_paths(specification_paths) do |name, data|
        document=validate_specification(name,data)
        @specifications[document["name"]]=document
      end
      document
    end

    private
    def validate_specification( specification_name, specification_yaml )
      sorted_schemas = @schemas.sort
      head_schema = sorted_schemas.pop() #Try the highest version schema first.
      head_errors = [] #If all schemas fail only return errors for the head spec
      failure_msgs = []
      specification_document = _validate_specification(head_schema[1],specification_yaml){|errors| head_errors=errors}

      until sorted_schemas.empty? or head_errors.empty? #Attempt other schemas if head fails
        schema = sorted_schemas.pop()
        schema_errors = []
        specification_document = _validate_specification( schema[1],specification_yaml ){|errors| schema_errors=errors}
        if schema_errors.empty? #If succeeded in validating against an old schema
          #We're not at head, call for transformation to latest style, schema[0] is name
          return TransformHelper.new( :log=> @log ).transform( schema[0], specification_document )
        end
      end

      #If all schemas fail then we assume they are using the latest schema..
      err_flag = parse_errors(head_errors) do |linenum, column, path, message|
        failure_msgs.push "[line #{linenum}, col #{column}] [#{path}] #{message}" # kwalify custom parser
      end
      raise ApplianceValidationError, %(The appliance specification "#{specification_name}" was invalid according to schema "#{head_schema[0]}":\n#{failure_msgs.join("\n")}") if err_flag
      specification_document
    end

    def _validate_specification( schema_document, specification_yaml )
      validator = ApplianceValidator.new( schema_document )
      parser = Kwalify::Yaml::Parser.new( validator )
      document = parser.parse( specification_yaml )
      yield parser.errors()
      document
    end

    def validate_schema( schema_name, schema_yaml )
      #Special validator bound to the kwalify meta schema
      meta_validator = Kwalify::MetaValidator.instance()
      #Validate schema definition
      document = Kwalify::Yaml.load( schema_yaml )
      #Do _NOT_ use the Kwalify parser for Meta-parsing! Parser for the meta is buggy and does not work as documented!
      #The CLI app seems to unintentionally work around the issue. Only validate using older/less useful method
      errors = meta_validator.validate( document )
      failure_msgs=[]
      err_flag = parse_errors(errors) do |linenum, column, path, message|
        failure_msgs.push "[#{path}] #{message}"#Internal parser has no linenum/col support
      end
      raise SchemaValidationError, "Unable to continue due to invalid schema #{schema_name}:\n#{failure_msgs.join("\n")}" if err_flag
      document
    end

    def resolve_name( _path )
      path=_path.split("/")
      return path unless path.is_a?(Array)
      path.reverse_each do |elem|
        unless elem =~ /[\d]+/ #unless integer
          return elem
        end
      end
      "ROOT"
    end

    def parse_errors( errors )
      p_errs=(errors && !errors.empty?)
      if p_errs #Then there was a problem
        errors.each do |err|
        message = case err.error_symbol
          when :pattern_unmatch then
            sprintf(@@messages[:pattern_unmatch],err.value,resolve_name(err.path))
          else
            err.message
        end
        yield err.linenum, err.column, err.path, message
        end
      end
      p_errs
    end
    #Get rid of file extension from name blah.yaml => blah, fred.xml => fred
    def parse_paths( paths=[] )
      paths.each do |p|
        # TODO decide whether to raise own exception or let system do its own thing...
        #raise SystemCallError, "The expected file #{p} does not exist." if not File.exist?(p)
        yield File.basename(p).gsub(/\.[^\.]+$/,''), File.read(p)
      end
    end
  end
end