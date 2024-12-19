#!/bin/bash

TEMP_VAULT_DIR="/vault/temp"
STORAGE_VAULT_DIR="/vault/storage"
HASH_VAULT_DIR="/vault/hash"
FILES_VAULT_DIR="/vault/files"
ARGS="$1"

mkdir -p "$FILES_VAULT_DIR"
mkdir -p "$HASH_VAULT_DIR"
mkdir -p "$STORAGE_VAULT_DIR"
mkdir -p "$TEMP_VAULT_DIR"

#if [ -d "/ramdisk/hash" ]
#then
#	echo "Removendo ramdisk..."
#	rm -r "/ramdisk/hash"
#fi

#echo "Carregando RAMDISK..."
#mkdir -p "/ramdisk"
#cp -r "/vault/hash" "/ramdisk/hash"
mkdir -p /vault/hash.old
echo "Analizando arquivos, aguarde..."

if [ ! -f /vault/hash.old/counter ]
then
	echo "0" > /vault/hash.old/counter
fi

# Iterar sobre todos os arquivos no diretório e subdiretórios
find "$TEMP_VAULT_DIR" -type f | while IFS= read -r file; do
    # Calcular o hash MD5 do arquivo
    hash=$(md5sum "$file" | awk '{print $1}')

    # Adicionar linha no arquivo de saída

	if [ ! -d "/vault/hash/$hash" ]
	then
	   # Criar nova entrada hash e mover o arquivo:
	   mkdir -p "/vault/hash/$hash"
	   NEW_FILE="${file/'temp'/'storage'}"
	   FILE_DIR=$(dirname "$NEW_FILE")
           mkdir -p "$FILE_DIR"
	   mv "$file" "/vault/files/$hash"
	   ln -s "/vault/files/$hash" "$NEW_FILE"
	   #echo  "/vault/files/$hash $NEW_FILE"
	   echo "$file" >> "/vault/hash/$hash/files.txt"
    	   echo "[$(date +%H:%M:%S)] ADD: $hash $file"
	else
           if ! grep -Fxq "$file" "/vault/hash/$hash/files.txt"; then
	        echo "$file" >> "/vault/hash/$hash/files.txt"
		rm "$file"
		NEW_FILE="${file/'temp'/'storage'}"
		FILE_DIR=$(dirname "$NEW_FILE")
	        mkdir -p "$FILE_DIR"
		ln -s "/vault/files/$hash" "$NEW_FILE"

		#if [ "x$ARGS" == "xdebug" ]
		#then
			
	     	        #echo "[$(date +%H:%M:%S)] UPD: $hash $file"
			SIZE=$(du "$NEW_FILE" -h -L)
                        echo "[$(date +%H:%M:%S)] UPD: $SIZE $hash $file"
		#fi
	   fi
	fi

done

COUNTER=$( cat /vault/hash.old/counter )
COUNTER=$(($COUNTER+1))

echo "$COUNTER" > /vault/hash.old/counter

echo "Criando backup da tabela hash atual..."
mksquashfs /vault/hash /vault/hash.old/hash_backup_$COUNTER.squashfs
#rm -r /vault/hash

#echo "Descarregando nova tabela hash da ramdisk..."
#mv -f /ramdisk/hash /vault/hash

#rsync -av --include='*/' --exclude='*' /vault/temp/ /vault/storage/

find /vault/temp/ -type d -empty -delete
mkdir -p /vault/temp 
