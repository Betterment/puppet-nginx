require 'formula'

class Nginx < Formula
  homepage 'http://nginx.org/'
  url 'http://nginx.org/download/nginx-1.6.2.tar.gz'
  sha256 'b5608c2959d3e7ad09b20fc8f9e5bd4bc87b3bc8ba5936a513c04ed8f1391a18'
  version '1.6.2-boxen1'

  depends_on 'pcre'
  depends_on "passenger" => :optional
  depends_on "openssl"

  skip_clean 'logs'

  option "with-passenger", "Compile with support for Phusion Passenger module"
  option "with-webdav", "Compile with support for WebDAV module"
  option "with-debug", "Compile with support for debug log"
  option "with-spdy", "Compile with support for SPDY module"
  option "with-gunzip", "Compile with support for gunzip module"

  def passenger_config_args
      passenger_root = `passenger-config --root`.chomp

      if File.directory?(passenger_root)
        return "--add-module=#{passenger_root}/ext/nginx"
      end

      puts "Unable to install nginx with passenger support. The passenger"
      puts "gem must be installed and passenger-config must be in your path"
      puts "in order to continue."
      exit
  end

  def install
    args = ["--prefix=#{prefix}",
            "--with-http_ssl_module",
            "--with-pcre",
            "--with-ipv6",
            "--with-cc-opt='-I#{HOMEBREW_PREFIX}/include'",
            "--with-ld-opt='-L#{HOMEBREW_PREFIX}/lib'",
            "--conf-path=/opt/boxen/config/nginx/nginx.conf",
            "--pid-path=/opt/boxen/data/nginx/nginx.pid",
            "--lock-path=/opt/boxen/data/nginx/nginx.lock"]

    args << passenger_config_args if build.with? "passenger"
    args << "--with-http_dav_module" if build.with? "webdav"
    args << "--with-debug" if build.with? "debug"
    args << "--with-http_spdy_module" if build.with? "spdy"
    args << "--with-http_gunzip_module" if build.with? "gunzip"

    system "./configure", *args
    system "make"
    system "make install"
    man8.install "objs/nginx.8"

    # remove unnecessary config files
    system "rm -rf #{etc}/nginx"
  end
end
