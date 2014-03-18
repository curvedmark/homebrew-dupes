require 'formula'

class Httpd < Formula
  homepage 'http://httpd.apache.org/'
  url 'http://apache.tradebit.com/pub/httpd/httpd-2.4.9.tar.bz2'
  sha1 '646aedbf59519e914c424b3a85d846bf189be3f4'

  depends_on 'apr'
  depends_on 'apr-util'
  depends_on 'pcre'

  def install
    # install custom layout
    File.open('config.layout', 'w') { |f| f.write(httpd_layout) };

    system "./configure",
      "--enable-layout=Homebrew",
      "--enable-mods-shared=all",
      "--with-apr=#{Formula.factory('apr').opt_prefix}",
      "--with-apr-util=#{Formula.factory('apr-util').opt_prefix}",
      "--with-pcre=#{Formula.factory('pcre').opt_prefix}"

    system "make"
    system "make install"
    (var/'apache2/log').mkpath
    (var/'apache2/run').mkpath
  end

  plist_options :manual => 'apachectl'

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/sbin/apachectl</string>
        <string>-DFOREGROUND</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  def httpd_layout
    return <<-EOS.undent
      <Layout Homebrew>
          prefix:        #{prefix}
          exec_prefix:   ${prefix}
          bindir:        ${exec_prefix}/bin
          sbindir:       ${exec_prefix}/bin
          libdir:        ${exec_prefix}/lib
          libexecdir:    ${exec_prefix}/libexec
          mandir:        #{man}
          sysconfdir:    #{etc}/apache2
          datadir:       #{var}/www
          installbuilddir: ${datadir}/build
          errordir:      ${datadir}/error
          iconsdir:      ${datadir}/icons
          htdocsdir:     ${datadir}/htdocs
          manualdir:     ${datadir}/manual
          cgidir:        #{var}/apache2/cgi-bin
          includedir:    ${prefix}/include/apache2
          localstatedir: #{var}/apache2
          runtimedir:    #{var}/run/apache2
          logfiledir:    #{var}/log/apache2
          proxycachedir: ${localstatedir}/proxy
      </Layout>
      EOS
  end
end
