module MsChapAuth

  def hexlify(msg)
    msg.unpack('H*').first
  end

  def unhexlify(msg)
    msg.scan(/../).collect { |c| c.to_i(16).chr }.join
  end

  def test_key key, challenge
    des = OpenSSL::Cipher::DES.new('ECB')
    des.encrypt
    des.key = key
    des.update challenge
    des.update challenge
  end

  def ntlm_challenge_response word, challenge

    uword = word.encode('iso-8859-1').encode('utf-16le')
    ntlmhash = md4_hash uword

    response = []

    response.push(test_key(key56_to_key64(ntlmhash[0...14]), challenge))
    response.push(test_key(key56_to_key64(ntlmhash[14...28]), challenge))
    response.push(test_key(key56_to_key64(ntlmhash[28...ntlmhash.length] + '0000000000'), challenge))
    hexlify(response[0]) + hexlify(response[1]) + hexlify(response[2])
  end


  def md4_hash word
    md4 = OpenSSL::Digest::MD4.new
    return md4.hexdigest(word)
  end

  def set_key_odd_parity key
    for pos in 0..key.length - 1
      for k in 0..6
        bit = 0
        t = key[pos] >> k
        bit = (t ^ bit) & 0x1
      end
      key[pos] = (key[pos] & 0xFE) | bit
    end
    return key
  end

  def key56_to_key64 key_raw
    key_raw = unhexlify(key_raw)
    key_56 = []
    key_raw.split("").each {|c| key_56.push(c.ord)}

    key = []
    (0..7).to_a.each {|i| key.push(0)}

    key[0] = key_56[0]
    key[1] = ((key_56[0] << 7) & 0xFF) | (key_56[1] >> 1);
    key[2] = ((key_56[1] << 6) & 0xFF) | (key_56[2] >> 2);
    key[3] = ((key_56[2] << 5) & 0xFF) | (key_56[3] >> 3);
    key[4] = ((key_56[3] << 4) & 0xFF) | (key_56[4] >> 4);
    key[5] = ((key_56[4] << 3) & 0xFF) | (key_56[5] >> 5);
    key[6] = ((key_56[5] << 2) & 0xFF) | (key_56[6] >> 6);
    key[7] =  (key_56[6] << 1) & 0xFF;

    key = set_key_odd_parity(key)

    keyout = ''
    key.each {|k| keyout += k.chr}
    return keyout

  end

  def get_otp username
    query = "select auth_key from users where email like '#{username}@%' limit 1"
    connect = Mysql2::Client.new(:host => "host", :username => "username", :password => "password", :database => "db_name")

    results = connect.query(query)
    otp_hash = results.to_a[0]['auth_key']
    connect.close

    return ROTP::TOTP.new(otp_hash).now()
  end

  def nt_password_hash password
    md4 = OpenSSL::Digest::MD4.new
    md4.digest(password)
  end

  def get_nt_key password
    unicode_pwd = password.encode('iso-8859-1').encode('utf-16le')
    pwd_hash = nt_password_hash(unicode_pwd)
    nt_key   = nt_password_hash(pwd_hash)
    return hexlify(nt_key)
  end

  def authenticate_ms_chap password, challenge, response
    if ntlm_challenge_response(password, unhexlify(challenge)) == response
      return "NT_KEY: " + get_nt_key(password).upcase
    end
    return ("NT_STATUS_UNSUCCESSFUL: Failure (0xC0000001)")
  end


end
