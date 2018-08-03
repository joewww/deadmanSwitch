FROM ubuntu:16.04

# docker run -d -p 8080:8080 -it --entrypoint "http-server" DeadmanSwitch

RUN apt-get update
RUN apt-get install -y nodejs npm nodejs-legacy
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
