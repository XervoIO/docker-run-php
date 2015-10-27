FROM onmodulus/run-base

ENV DEBIAN_FRONTEND noninteractive

ADD . /opt/modulus
ENV PATH=/opt/modulus/bin:$PATH

#RUN /opt/modulus/bootstrap.sh

RUN /opt/modulus/apt.sh
RUN /opt/modulus/phpbrew.sh
RUN /opt/modulus/php.sh
RUN /opt/modulus/mongo.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
