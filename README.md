# looker-docker

This is a really basic definition of a container that is suitable for running
the Looker software (aka looker.com). Looker itself is not included; you will
need to obtain that separately.

The idea is to build and run the base image, in combination with a volume to
store all your models / configuration data.

To build, simply do something like:

    docker build -t looker .

Then, to run, this will demonstrate it working:

     docker run --volume /path/to/your/data/volume/:/home/looker/looker -P -ti looker

You can name the image as you please, and this works well with various forms of
orchestration, although right now this isn't designed to be clustered (and, indeed,
I'm not really sure how you'd do that - maybe make the data volume a GlusterFS or
something).

By default, the logs are output on standard out, which should be right for most setups.
