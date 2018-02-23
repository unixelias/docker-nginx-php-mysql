FROM mariadb

MAINTAINER Elias Alves <elias.alves@ufvjm.edu.br>


# Set languages and locales
RUN apt-get update && apt-get install -y locales tzdata \
	&& touch /usr/share/locale/locale.alias \
    && localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8 \
	&& echo "LC_ALL=pt_BR.UTF-8" >> /etc/environment \
	&& echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen \
	&& echo "LANG=pt_BR.UTF-8" > /etc/locale.conf \
	&& echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& echo "LANG=en_US.UTF-8" > /etc/locale.conf \
    && echo "portuguese	pt_BR" >> /etc/locale.alias \
	&& echo "portuguese	pt_BR.UTF-8" >> /etc/locale.alias \
	&& echo "english	en_US" >> /etc/locale.alias \
	&& echo "english	en_US.UTF-8" >> /etc/locale.alias \
	&& locale-gen pt_BR pt_BR.UTF-8 en_US en_US.UTF-8 \
	&& dpkg-reconfigure -f noninteractive locales \
    && unlink /etc/localtime \
    && ln -s /usr/share/zoneinfo/Brazil/East /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 3306

CMD ["mysqld", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci"]