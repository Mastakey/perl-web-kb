cd ..
xcopy /Y /S config C:\Inetpub\perl-deployment\stage\perl-web-kb\config
xcopy /Y /S html C:\Inetpub\perl-deployment\stage\perl-web-kb\html
xcopy /Y /S tmpl C:\Inetpub\perl-deployment\stage\perl-web-kb\tmpl
cd cgi-bin
xcopy /Y /S admin C:\Inetpub\perl-deployment\stage\cgi-bin\perl-web-kb\admin
xcopy /Y /S func C:\Inetpub\perl-deployment\stage\cgi-bin\perl-web-kb\func
xcopy /Y /S lib C:\Inetpub\perl-deployment\stage\cgi-bin\perl-web-kb\lib
xcopy /Y /S web C:\Inetpub\perl-deployment\stage\cgi-bin\perl-web-kb\web
cd ..
cd automation