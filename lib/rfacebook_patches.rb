# http://nhw.pl/wp/2008/06/13/uploading-photos-to-facebook-with-rfacebook
# http://www.inter-sections.net/2007/10/21/integration-testing-with-rfacebook-solving-the-session-problem

module RFacebook
  class FacebookWebSession
    def get_fb_sig_params(originalParams)
      # setup
      timeout = 48*3600
      prefix = "fb_sig_"
      # get the params prefixed by "fb_sig_" (and remove the prefix)
      sigParams = {}
      originalParams.each do |k,v|
        oldLen = k.length
        newK = k.sub(prefix, "")
        if oldLen != newK.length
          sigParams[newK] = v
        end
      end
      # # handle invalidation
      # if (timeout and (sigParams["time"].nil? or (Time.now.to_i - sigParams["time"].to_i > timeout.to_i)))
      #   # invalidate if the timeout has been reached
      #   #log_debug "** RFACEBOOK(GEM) - fbparams is empty because the signature was timed out"
      #   sigParams = {}
      # end
      #
      # # check that the signatures match
      # expectedSig = originalParams["fb_sig"]
      # if !(sigParams and expectedSig and generate_signature(sigParams, @api_secret) == expectedSig)
      #   # didn't match, empty out the params
      #   #log_debug "** RFACEBOOK(GEM) - fbparams is empty because the signature did not match"
      #   sigParams = {}
      # end
      return sigParams
    end

    BOUNDARY_CHARS = ("A".."Z").to_a + ("a".."z").to_a + ("1".."9").to_a 

    def photos_upload(params = {})
      params = (params || {}).dup
      params[:method] = "facebook.photos.upload"
      params[:api_key] = FACEBOOK["key"]
      params[:v] = API_VERSION
      params[:session_key] = session_key
      params[:call_id] = Time.now.to_f.to_s
      file = params.delete :file
      params[:sig] = signature(params)
      params[:type] or raise ArgumentError.new("Must supply parameter :type (content type)")
      params[:filename] or raise ArgumentError.new("Must supply parameter :filename")

      boundary = Array.new(60){ BOUNDARY_CHARS[rand(BOUNDARY_CHARS.size)] }.join

      params_as_arr = []
      params.each do |k,v|
        params_as_arr << text_to_multipart(k.to_s, v.to_s)
      end
      params_as_arr << file_to_multipart(params[:filename], params[:type], file)

      inner_boundary = '--' + boundary + "\r\n"
      end_boundary = "--" + boundary + "--\r\n"

      qry = params_as_arr.map{|p| inner_boundary + p }.join('') + end_boundary

      response = Net::HTTP.start(API_HOST).post2(API_PATH_REST, qry, "Content-type" => "multipart/form-data; boundary=" + boundary)

      handle_xml_response(response.body.to_s)
    end

    private

    def text_to_multipart(key, value)
    "Content-Disposition: form-data; name=\"#{key}\"\r\n" +
      "\r\n" +
      "#{value}\r\n"
    end

    def file_to_multipart(filename, mime_type, content)
      #"Content-Transfer-Encoding: binary\r\n" +
      "Content-Disposition: form-data; filename=\"#{CGI.escape(filename)}\"\r\n" +
        "Content-Type: #{mime_type}\r\n" +
        "\r\n" +
        "#{content}\r\n"
    end
  end
end
