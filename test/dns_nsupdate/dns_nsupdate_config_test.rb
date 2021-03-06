require 'test_helper'
require 'dns/dns'
require 'dns_nsupdate/dns_nsupdate'
require 'dns_nsupdate/dns_nsupdate_gss'
require 'dns_nsupdate/dns_nsupdate_main'
require 'dns_nsupdate/dns_nsupdate_gss_main'

class DnsNsupdateConfigTest < Test::Unit::TestCase
  def test_initialize_nsupdate_returns_no_error_with_missing_key_setting
    Proxy::Dns::Nsupdate::Plugin.settings.stubs(:dns_key).returns(nil)
    assert Proxy::Dns::Nsupdate::Record.new(:fqdn => 'example.com')
  end

  def test_initialize_nsupdate_returns_error_with_missing_key_file
    Proxy::Dns::Nsupdate::Plugin.settings.stubs(:dns_key).returns('./no-such-key')
    assert_raise RuntimeError do
      Proxy::Dns::Nsupdate::Record.new(:fqdn => 'example.com')
    end
  end

  def test_initialize_nsupdate_gss_succeeds
    Proxy::Dns::NsupdateGSS::Plugin.settings.expects(:dns_tsig_keytab).returns('./key')
    Proxy::Dns::NsupdateGSS::Plugin.settings.expects(:dns_tsig_principal).returns('a@B')
    File.expects(:exist?).with('./key').returns(true)
    record = Proxy::Dns::NsupdateGSS::Record.new(:fqdn => 'example.com')
    assert record
    assert_equal './key', record.tsig_keytab
    assert_equal 'a@B', record.tsig_principal
  end

  def test_initialize_nsupdate_gss_returns_error_with_missing_keykey_file
    Proxy::Dns::NsupdateGSS::Plugin.settings.expects(:dns_tsig_keytab).returns('./key')
    Proxy::Dns::NsupdateGSS::Plugin.settings.expects(:dns_tsig_principal).returns('a@B')
    File.expects(:exist?).with('./key').returns(false)
    assert_raise RuntimeError do
      Proxy::Dns::NsupdateGSS::Record.new(:fqdn => 'example.com')
    end
  end
end
