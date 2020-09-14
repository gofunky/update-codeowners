FROM casperdcl/git-fame:1.12.2

RUN apk update && apk add --no-cache npm
RUN npm install --global github-username-cli

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
