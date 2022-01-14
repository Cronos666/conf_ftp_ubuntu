#!/bin/bash

while :
do
        clear
        echo -e "\n MENU \n -------\n 1. Instalacja servera FTP\n 2. Automatyczna konfiguracja FTP\n 3. Dodaj użytkownika do listy kont ftp\n 4. Szyfrowanie\n 5. Status usługi\n 6. Wyjście"
        read menu

        case $menu in

                1)
                        echo "Pakiet zostanie zainstalowany/uaktualniony"
                        sudo apt update
                        sudo apt install vsftpd -y
                        ;;

                2)
                        echo -n "Zostanie stworzone nowe konto jako server FTP kontynuować? [T/N] "
                        read wyb

                        if [ $wyb = T ]
                        then
                                echo -n "Podaj nazwę dla konta ftp: "
                                read ac

                                sudo useradd $ac
                                sudo passwd $ac
                                sudo cp /etc/passwd /etc/passwd.copy
                                sudo sed -i "s|/home/$ac:/bin/sh|/home/$ac:/usr/bin/nologin|g" /etc/passwd
								sudo mkdir /home/$ac
								sudo chown -R $ac /home/$ac

                                sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.copy
                                echo -e "#\n#new-conf\n#-----------------------\nwrite_enable=YES\nchroot_local_user=YES\nallow_writeable_chroot=YES\n" | sudo tee -a /etc/vsftpd.conf
								echo "$ac" | sudo tee -a /etc/vsftpd.users
								echo "userlist_enable=YES" | sudo tee -a /etc/vsftpd.conf
								echo "userlist_file=/etc/vsftpd.users" | sudo tee -a /etc/vsftpd.conf
								echo "userlist_deny=NO" | sudo tee -a /etc/vsftpd.conf
								echo "/usr/bin/nologin" | sudo tee -a /etc/shells
								sudo systemctl restart vsftpd.service
                        fi
                        ;;
		
		3)
			echo -n "Podaj nazwę konta: "
			read acc
			echo "$acc" >> /etc/vsftpd.userlist
			;;	
		
		4)
			echo "Program wygeneruje klucze i włączy szyfrowanie usługi FTP"
			echo -n "Liczba dni do wygaśnięcia klucza: " 
			read days
			sudo openssl req -x509 -nodes -days $days -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem			
			
			echo -e "#\nrsa_cert_file=/etc/ssl/private/vsftpd.pem\nrsa_private_key_file=/etc/ssl/private/vsftpd.pem\nssl_enable=YES\nforce_local_data_ssl=YES\nforce_local_logins_ssl=YES\nssl_tlsv1=YES\nssl_sslv2=NO\nssl_sslv3=NO" | sudo tee -a /etc/vsftpd.conf
			;;
               
	        5)
			sudo systemctl status vsftpd.service
			echo -n "Nacisinij Enter aby wyjść"
			read en
			;;   
	       	
		6)
                        clear
                        exit
                        ;;
		
                *)
                        echo -e "Nie ma takiej opcji\n"
        esac
done
