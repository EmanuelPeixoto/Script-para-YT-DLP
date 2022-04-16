	Menu(){
	clear
		echo "Menu de download de arquivos"
		echo "------------------------------"
		echo ""
		echo "Escolha enviando o número."
		echo "1 - MP4 com link."
		echo "2 - MP3 com link."
		echo "3 - MP4 com arquivo."
		echo "4 - MP3 com arquivo."
		echo ""
		echo "0 - Sair."
		echo ""
		echo -n "Qual a Opção: "
		read MODO
		
		case $MODO in
		1) MP4L ;;
		2) MP3L ;;
		3) MP4A ;;
		4) MP3A ;;
		0) SAIR ;;
		*) echo "" ; echo "Opção desconhecida." ; sleep 2 ; Menu ;;
		
		esac
		
}	
	
		MP4L(){
		clear
		echo "Modo MP4 com link carregado."
		echo -n "Informe o link: "
		read LINK
		echo ""
		echo ""
		yt-dlp --config-location ./Modos/MP4L.conf $LINK
		Menu_Saida;
		}
		
		MP3L(){
		clear
		echo "Modo MP3 com link carregado."
		echo -n "Informe o link: "
		read LINK
		echo ""
		echo ""
		yt-dlp --config-location ./Modos/MP3L.conf $LINK
		Menu_Saida;
		}
		
		MP4A(){
		clear
		echo "Modo MP4 com arquivo carregado."
		echo "Verificando se existe o arquivo de lista"
		if [ -f ./lista.txt ];
		then 
		echo "O arquivo já existe."
		echo ""
		echo "Feche o bloco de notas ao terminar de editar o arquivo."
		notepad.exe ./lista.txt
		else
		echo "Criando arquivo."
		touch lista.txt
		echo ""
		echo "Feche o bloco de notas ao terminar de editar o arquivo."
		notepad.exe ./lista.txt
		fi
		echo ""
		echo ""
		yt-dlp --config-location ./Modos/MP4A.conf
		Menu_Saida;
		}
		
		MP3A(){
		clear
		echo "Modo MP3 com arquivo carregado."
		echo "Verificando se existe o arquivo de lista"
		if [ -f ./lista.txt ];
		then 
		echo "O arquivo já existe."
		echo ""
		echo "Feche o bloco de notas ao terminar de editar o arquivo."
		notepad.exe ./lista.txt
		else
		echo "Criando arquivo."
		touch lista.txt
		echo ""
		echo "Feche o bloco de notas ao terminar de editar o arquivo."
		notepad.exe ./lista.txt
		fi
		echo ""
		echo ""
		yt-dlp --config-location ./Modos/MP3A.conf
		Menu_Saida;
		}
		
		SAIR(){
		echo "Saindo..."
		exit
		}
		

	
	Menu_Saida(){
	echo ""
	echo ""
	echo ""
	echo "Escolha enviando o número."
	echo "1 - Voltar ao menu principal."
	echo "0 - Sair."
	echo -n "Opção: "
	read MENU
	case $MENU in
		1) Menu ;;
		0) SAIR ;;
		*) echo "" ; echo "Opção desconhecida." ; sleep 2 ; Menu_Saida ;;
	esac
	}

Menu