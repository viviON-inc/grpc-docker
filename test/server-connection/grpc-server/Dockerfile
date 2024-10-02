FROM node:12-bullseye-slim

WORKDIR /work

RUN apt update -y && \
    apt install -y git

RUN git clone -b @grpc/grpc-js@1.11.3 --depth 1 --shallow-submodules https://github.com/grpc/grpc-node
RUN cd grpc-node/examples && \
    npm install && \
    cd helloworld/dynamic_codegen

CMD [ "node", "/work/grpc-node/examples/helloworld/dynamic_codegen/greeter_server.js" ]
