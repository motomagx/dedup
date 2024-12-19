#!/bin/bash

MAIN_DIR="/vault"
TEMP_VAULT_DIR="$MAIN_DIR/temp"
STORAGE_VAULT_DIR="$MAIN_DIR/storage"
HASH_VAULT_DIR="$MAIN_DIR/hash"
FILES_VAULT_DIR="$MAIN_DIR/files"
HASH_SNAPSHOTS="$MAIN_DIR/hash_snapshots"
STORAGE_SNAPSHOTS="$MAIN_DIR/storage_snapshots"
ARGS="$1"

mkdir -p "$FILES_VAULT_DIR"
mkdir -p "$HASH_VAULT_DIR"
mkdir -p "$STORAGE_VAULT_DIR"
mkdir -p "$TEMP_VAULT_DIR"
mkdir -p "$STORAGE_SNAPSHOTS"
mkdir -p "$HASH_SNAPSHOTS"

echo "Analizando arquivos, aguarde..."

# Iterar sobre todos os arquivos no diretório e subdiretórios
find "$TEMP_VAULT_DIR" -type f | while IFS= read -r file; do
    # Calcular o hash MD5 do arquivo
    hash=$(md5sum "$file" | awk '{print $1}')

    # Adicionar linha no arquivo de saída

	if [ ! -d "/vault/hash/$hash" ]
	then
	   # Criar nova entrada hash e mover o arquivo:
	   mkdir -p "$HASH_VAULT_DIR/$hash"
	   NEW_FILE="${file/'temp'/'storage'}"
	   FILE_DIR=$(dirname "$NEW_FILE")
           mkdir -p "$FILE_DIR"
	   mv "$file" "$FILES_VAULT_DIR/$hash"
	   ln -s "$FILES_VAULT_DIR/$hash" "$NEW_FILE"
	   echo "$file" >> "$HASH_VAULT_DIR/$hash/files.txt"
    	   echo "[$(date +%H:%M:%S)] ADD: $hash $file"
	else
           if ! grep -Fxq "$file" "$HASH_VAULT_DIR/$hash/files.txt"; then
	        echo "$file" >> "$HASH_VAULT_DIR/$hash/files.txt"
		rm "$file"
		NEW_FILE="${file/'temp'/'storage'}"
		FILE_DIR=$(dirname "$NEW_FILE")
	        mkdir -p "$FILE_DIR"
		ln -s "$FILES_VAULT_DIRs/$hash" "$NEW_FILE"

		if [ "x$ARGS" == "xdebug" ]
		then
			SIZE=$(du "$NEW_FILE" -h -L)
                        echo "[$(date +%H:%M:%S)] UPD: $SIZE $hash $file"
		fi
	   fi
	fi
done

echo "Sincronizando pastas, aguarde..."
rsync -av --include='*/' --exclude='*' "$TEMP_VAULT_DIR" "$STORAGE_VAULT_DIR"
find "$TEMP_VAULT_DIR" -type d -empty -delete
mkdir -p "$TEMP_VAULT_DIR" 

echo "Criando backup da tabela hash atual..."
mksquashfs "$HASH_VAULT_DIR" "$HASH_SNAPSHOTS/hash_$(date +%Y-%M-%d_%Hh%Mm%Ss).squashfs"

echo "Criando backup da estrutura compartilhada atual..."
mksquashfs "$STORAGE_VAULT_DIR" "$STORAGE_SNAPSHOTS/storage_$(date +%Y-%M-%d_%Hh%Mm%Ss).squashfs"
