FROM ubuntu:16.04

# BUILD:
# git clone https://github.com/joewww/deadmanSwitch.git
# docker build -t deadmanswitch deadmanSwitch

# RUN:
## Web UI:
# docker run -d -p 8080:8080 -it --entrypoint "http-server" deadmanswitch
## -or- Shell (for development)
# docker run -it --entrypoint /bin/bash deadmanswitch


RUN apt-get update
RUN apt-get install -y npm nodejs-legacy curl vim
RUN npm install -g http-server

CMD mkdir {css,gfx,js}

CMD mkdir -p installed_contracts/zeppelin/contracts/ownership/
CMD mkdir -p installed_contracts/zeppelin/contracts/math/
CMD mkdir -p installed_contracts/zeppelin/contracts/lifecycle/

COPY installed_contracts/zeppelin/contracts/ownership/Ownable.sol installed_contracts/zeppelin/contracts/ownership/Ownable.sol
COPY installed_contracts/zeppelin/contracts/math/SafeMath.sol installed_contracts/zeppelin/contracts/math/SafeMath.sol
COPY installed_contracts/zeppelin/contracts/lifecycle/Destructible.sol installed_contracts/zeppelin/contracts/lifecycle/Destructible.sol
COPY installed_contracts/zeppelin/contracts/lifecycle/Pausable.sol installed_contracts/zeppelin/contracts/lifecycle/Pausable.sol

COPY css/style.css css/style.css
COPY css/bootstrap.css css/bootstrap.css

COPY gfx/download-metamask-dark.png gfx/download-metamask-dark.png
COPY gfx/rinkeby-help.png gfx/rinkeby-help.png
COPY gfx/nothin.png gfx/nothin.png

COPY js/jquery-3.2.1.min.js js/jquery-3.2.1.min.js
COPY js/bootstrap.min.js js/bootstrap.min.js
COPY js/web3.min.js js/web3.min.js
COPY js/deadmanSwitch.js js/deadmanSwitch.js

COPY index.html .

# Truffle
CMD mkdir {test,migrations,contracts}

COPY test/TestDeadmanSwitch.sol test/TestDeadmanSwitch.sol
COPY test/TestDeadmanSwitch.js test/TestDeadmanSwitch.js

COPY migrations/1_initial_migration.js migrations/1_initial_migration.js
COPY migrations/2_deploy_contracts.js migrations/2_deploy_contracts.js

COPY contracts/Migrations.sol contracts/Migrations.sol
COPY contracts/DeadmanSwitch.sol contracts/DeadmanSwitch.sol

COPY truffle.js .
COPY ethpm.json .

RUN curl -sL https://deb.nodesource.com/setup_8.x |  bash -
RUN apt-get install -y nodejs
RUN npm install -g truffle
RUN npm install -g ganache-cli
