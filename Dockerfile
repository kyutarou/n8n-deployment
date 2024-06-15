# ベースイメージとしてn8nのベースイメージを使用
ARG NODE_VERSION=20
FROM n8nio/base:${NODE_VERSION}

# n8nのバージョンを引数として受け取る
ARG N8N_VERSION
RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

# 環境変数の設定
ENV N8N_VERSION=${N8N_VERSION}
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=stable
ENV N8N_PORT=8080

# n8nのインストールと不要なファイルの削除
RUN set -eux; \
    npm install -g --omit=dev n8n@${N8N_VERSION} --ignore-scripts && \
    npm rebuild --prefix=/usr/local/lib/node_modules/n8n sqlite3 && \
    rm -rf /usr/local/lib/node_modules/n8n/node_modules/@n8n/chat && \
    rm -rf /usr/local/lib/node_modules/n8n/node_modules/n8n-design-system && \
    rm -rf /usr/local/lib/node_modules/n8n/node_modules/n8n-editor-ui/node_modules && \
    find /usr/local/lib/node_modules/n8n -type f -name ".ts" -o -name ".js.map" -o -name "*.vue" | xargs rm -f && \
    rm -rf /root/.npm

# エントリーポイントスクリプトをコピー
COPY docker-entrypoint.sh /

# n8n用のディレクトリを作成し、適切な権限を設定
RUN mkdir .n8n && chown node .n8n

# シェルを/bin/shに設定し、ユーザーをnodeに切り替え
ENV SHELL /bin/sh
USER node

# 環境変数を設定してポート8080を使用するように指定
EXPOSE 8080

# エントリーポイントの設定
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
