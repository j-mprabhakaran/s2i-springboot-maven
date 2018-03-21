# springboot-maven3-centos
#
# This image provide a base for running Spring Boot based applications. 
# It provides a base Java 8 installation and Maven 3.

FROM openshift/base-centos7
MAINTAINER Prabhakaran Jayaraman Masani (pjayaramanma@dxc.com)

EXPOSE 8080

ENV JAVA_VERSON 1.8.0
ENV MAVEN_VERSION 3.3.9
ENV TOMCAT_MAJOR_VERSION 8 
ENV TOMCAT_MINOR_VERSION 8.0.32 
ENV CATALINA_HOME /tomcat 
ENV JAVA_HOME /usr/lib/jvm/java
ENV MAVEN_HOME /usr/share/maven

LABEL io.k8s.description="Platform for building and running Spring Boot applications" \
      io.k8s.display-name="Spring Boot Maven 3" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,java8,maven,maven3,springboot"

RUN yum update -y && \
  yum install -y curl && \
  yum install -y java-$JAVA_VERSON-openjdk java-$JAVA_VERSON-openjdk-devel && \
  yum clean all

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
  
RUN wget -q -e use_proxy=yes https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32.tar.gz && \
    tar -zxf apache-tomcat-*.tar.gz &&\
    rm -f apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat   
	
RUN groupadd -r safe 
RUN useradd  -r -g safe safe 
RUN mkdir -p /tomcat/webapps /TempDirRoot
RUN chown -R 1001:1001 /tomcat /TempDirRoot 
RUN chmod -R 777 /tomcat /TempDirRoot 

RUN cd /tomcat/webapps/; rm -rf ROOT docs examples host-manager manager 	

# Add configuration files, bashrc and other tweaks
# COPY ./s2i/bin/ $STI_SCRIPTS_PATH

COPY ./.s2i/bin/ /usr/libexec/s2i

RUN chown -R 1001:0 /opt/app-root
USER 1001

# Set the default CMD to print the usage of the language image
ENTRYPOINT ${CATALINA_HOME}/bin/catalina.sh run
