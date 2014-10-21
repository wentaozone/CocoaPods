require 'cocoapods/external_sources/abstract_external_source'
require 'cocoapods/external_sources/downloader_source'
require 'cocoapods/external_sources/path_source'
require 'cocoapods/external_sources/podspec_source'

module Pod
  # Provides support for initializing the correct concrete class of an external
  # source.
  #
  module ExternalSources
    # @return [AbstractExternalSource] an initialized instance of the concrete
    #         external source class associated with the option specified in the
    #         hash.
    #
    def self.from_dependency(dependency, podfile_path)
      name   = dependency.root_name
      params = dependency.external_source

      if klass = concrete_class_from_params(params)
        klass.new(name, params, podfile_path)
      else
        msg = "Unknown external source parameters for `#{name}`: `#{params}`"
        raise Informative, msg
      end
    end

    # @return [Class]
    #
    def self.concrete_class_from_params(params)
      if params.key?(:podspec)
        PodspecSource
      elsif params.key?(:path)
        PathSource
      elsif params.key?(:local)
        UI.warn 'The `:local` option of the Podfile has been ' \
          'renamed to `:path` and it is deprecated.'
        PathSource
      elsif Downloader.strategy_from_options(params)
        DownloaderSource
      end
    end
  end
end
