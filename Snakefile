configfile: "config.yaml"
DOCKER_CMD="docker run -it -v `pwd`:/home/user -w /home/user/ fgajardoe/r-custom:latest Rscript "
rule run_script:
	input:
		config["Lista_de_cartolas"]
	output:
		config["Lista_de_cartolas"]+".report.html",
	shell:
		DOCKER_CMD+"finanzalo.R {input}"

