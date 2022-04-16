CriaEVerifica(){
 echo "Verificando se existem os arquivos necessários"
 
		TEXTMP4L="-f best --recode-video mp4 -P /Downloads # Melhor qualidade sempre - Força salvar vídeo em mp4 - Seleciona pasta para salvar"
		TEXTMP3L="-f best -x --audio-format mp3 -P /Downloads # Melhor qualidade sempre - Só áudio - Força salvar audio em mp3 - Seleciona pasta para salvar"
		TEXTMP4A="-f best --recode-video mp4 -a lista.txt -P /Downloads # Melhor qualidade sempre - Força salvar vídeo em mp4 - Ler arquivos em lotes - Seleciona pasta para salvar"
		TEXTMP3A="-f best -x --audio-format mp3 -a lista.txt -P /Downloads # Melhor qualidade sempre - Só audio - Força salvar audio em mp3 - Ler arquivos em lotes - Seleciona pasta para salvar"
 
		if [ -d ./Downloads ];
		then 
		echo "Pasta Downloads existe."
		else
		echo "Criando pasta de Downloads"
		mkdir Downloads
		fi
		
		if [ -d ./Modos ];
		then 
		echo "Pasta Modos existe."
		else
		echo "Criando pasta de Modos"
		mkdir Modos
		fi
		
		if [ -f ./Modos/MP4L.conf ];
		then 
		echo "Arquivo MP4L já existe."
		else
		echo "Criando arquivo MP4L"
		touch ./Modos/MP4L.conf
		echo $TEXTMP4L > ./Modos/MP4L.conf
		fi
		
		if [ -f ./Modos/MP3L.conf ];
		then 
		echo "Arquivo MP3L já existe."
		else
		echo "Criando arquivo MP3L"
		touch ./Modos/MP3L.conf
		echo $TEXTMP3L > ./Modos/MP3L.conf
		fi
		
		if [ -f ./Modos/MP4A.conf ];
		then 
		echo "Arquivo MP4A já existe."
		else
		echo "Criando arquivo MP4A"
		touch ./Modos/MP4A.conf
		echo $TEXTMP4A > ./Modos/MP4A.conf
		fi
		
		if [ -f ./Modos/MP3A.conf ];
		then 
		echo "Arquivo MP3A já existe."
		else
		echo "Criando arquivo MP3A"
		touch ./Modos/MP3A.conf
		echo $TEXTMP3A > ./Modos/MP3A.conf
		fi
		
		echo 
		echo 
		echo 
		echo "Tudo certo, redirecionando para o Menu principal"
		sleep 3
		Menu

}

	Menu(){
	clear
		echo "Menu de download de arquivos"
		echo "------------------------------"
		echo 
		echo "Escolha enviando o número."
		echo "1 - MP4 com link."
		echo "2 - MP3 com link."
		echo "3 - MP4 com arquivo."
		echo "4 - MP3 com arquivo."
		echo 
		echo 
		echo "9 - Sobre o software."
		echo 
		echo "0 - Sair."
		echo 
		echo -n "Qual a Opção: "
		read MODO
		
		case $MODO in
		1) MP4L ;;
		2) MP3L ;;
		3) MP4A ;;
		4) MP3A ;;
		9) clear ; echo "Criado por Emanuel Peixoto" ; echo ; echo "github.com/EmanuelPeixoto" ; echo "Esse software necessita do FFmpeg e YT-DLP instalado" ; echo ; echo "Pressione ENTER para voltar para o Menu principal." ; read ; Menu ;;
		0) SAIR ;;
		*) echo ; echo "Opção desconhecida." ; sleep 2 ; Menu ;;
		
		esac
		
}	
	
		MP4L(){
		clear
		echo "Modo MP4 com link carregado."
		echo -n "Informe o link: "
		read LINK
		echo 
		echo 
		yt-dlp --config-location ./Modos/MP4L.conf $LINK
		Menu_Saida;
		}
		
		MP3L(){
		clear
		echo "Modo MP3 com link carregado."
		echo -n "Informe o link: "
		read LINK
		echo 
		echo 
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
		echo 
		echo "Feche o bloco de notas ao terminar de editar o arquivo."
		notepad.exe ./lista.txt
		else
		echo "Criando arquivo."
		touch lista.txt
		echo 
		echo "Feche o bloco de notas ao terminar de editar o arquivo."
		notepad.exe ./lista.txt
		fi
		echo 
		echo 
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
		echo 
		echo "Feche o bloco de notas ao terminar de editar o arquivo."
		notepad.exe ./lista.txt
		else
		echo "Criando arquivo."
		touch lista.txt
		echo 
		echo "Feche o bloco de notas ao terminar de editar o arquivo."
		notepad.exe ./lista.txt
		fi
		echo 
		echo 
		yt-dlp --config-location ./Modos/MP3A.conf
		Menu_Saida;
		}
		
		SAIR(){
		echo "Saindo..."
		exit
		}
		

	
	Menu_Saida(){
	echo 
	echo 
	echo 
	echo "Escolha enviando o número."
	echo "1 - Voltar ao menu principal."
	echo "0 - Sair."
	echo -n "Opção: "
	read MENU
	case $MENU in
		1) Menu ;;
		0) SAIR ;;
		*) echo ; echo "Opção desconhecida." ; sleep 2 ; Menu_Saida ;;
	esac
	}

CriaEVerifica