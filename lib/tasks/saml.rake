namespace :saml do
  desc "Common SAML tasks"

  task :cert do
    if ENV['GATE_SAML_IDP_X509_CERTIFICATE'].blank?
      puts "[WARN] Certificate for SAML is not available."
      puts "[WARN] Please add it in env file with key name GATE_SAML_IDP_X509_CERTIFICATE."
      puts "[WARN] And then re-run your server."
      exit -1
    end

    puts ENV['GATE_SAML_IDP_X509_CERTIFICATE'].gsub("\\n", "\n").tr('"', '')
  end
end
