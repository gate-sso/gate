dev_user = User.create_user('dev', 'dev@a.c')
dev_user.generate_two_factor_auth
(1..6).each do |uid|
  user = User.create_user("dev#{uid}", "dev#{uid}@a.c")
  user.generate_two_factor_auth
end
group = Group.create(name: 'people')
User.all.each do |user|
  user.groups << group
  user.save!
end
AccessToken.create(token: 'a')

vpn = Vpn.create(name: 'dev-vpn', host_name: 'dev-vpn.example.com', ip_address: '1.2.3.4', uuid: 'FC29CB92-FC7E-4F0B-B938-7612DFDECC28')
HostMachine.create(name: 'SampleHost1')
HostMachine.create(name: 'SampleHost2')
vsd = VpnSearchDomain.create(search_domain: 'dev-search.vpn.example.com')
vdns = VpnDomainNameServer.create(server_address: '8.8.8.8')
vsmd = VpnSupplementalMatchDomain.create(supplemental_match_domain: 'match.domains')
vpn.vpn_search_domains << vsd
vpn.vpn_domain_name_servers << vdns
vpn.vpn_supplemental_match_domains << vsmd
vpn.save!
