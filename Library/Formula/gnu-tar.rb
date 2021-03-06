class GnuTar < Formula
  desc "GNU version of the tar archiving utility"
  homepage "https://www.gnu.org/software/tar/"
  url "http://ftpmirror.gnu.org/tar/tar-1.28.tar.gz"
  mirror "https://ftp.gnu.org/gnu/tar/tar-1.28.tar.gz"
  sha256 "6a6b65bac00a127a508533c604d5bf1a3d40f82707d56f20cefd38a05e8237de"

  option "with-default-names", "Do not prepend 'g' to the binary"

  bottle do
    revision 2
    sha256 "ec164a19cec89dd5fcec0fd1cc25f78d33b73bdf6d149bae586fa398d89fa2e9" => :el_capitan
    sha256 "0187700c9462dc4ff64bc157f0e7cf4e7c0bda1c96aa0a7aef6ed3522d5d3484" => :yosemite
    sha256 "732121b85fca598b1ba9e71b2aae6687a1642724d94e3e5f63acefd461dfdbd7" => :mavericks
    sha256 "f81f7d823d52f224087ec560e3542cd90b16e9b983ca68cd59cd2ec430236218" => :mountain_lion
  end

  # Fix for xattrs bug causing build failures on OS X:
  # https://lists.gnu.org/archive/html/bug-tar/2014-08/msg00001.html
  patch do
    url "https://gist.githubusercontent.com/mistydemeo/10fbae8b8441359ba86d/raw/e5c183b72036821856f9e82b46fba6185e10e8b9/gnutar-configure-xattrs.patch"
    sha256 "f2e56bb8afd1c641a7e5b81e35fdbf36b6fb66434b1e35caa8b55196b30c3ad9"
  end

  def install
    args = ["--prefix=#{prefix}", "--mandir=#{man}"]
    args << "--program-prefix=g" if build.without? "default-names"

    system "./configure", *args
    system "make", "install"

    # Symlink the executable into libexec/gnubin as "tar"
    (libexec/"gnubin").install_symlink bin/"gtar" => "tar" if build.without? "default-names"
  end

  def caveats
    if build.without? "default-names" then <<-EOS.undent
      gnu-tar has been installed as "gtar".

      If you really need to use it as "tar", you can add a "gnubin" directory
      to your PATH from your bashrc like:

          PATH="#{opt_libexec}/gnubin:$PATH"
      EOS
    end
  end

  test do
    tar = build.with?("default-names") ? bin/"tar" : bin/"gtar"
    (testpath/"test").write("test")
    system tar, "-czvf", "test.tar.gz", "test"
    assert_match /test/, shell_output("#{tar} -xOzf test.tar.gz")
  end
end
