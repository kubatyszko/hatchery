#!/usr/bin/ruby

require 'docker'
require 'json'

image = Docker::Image.create('fromImage' => 'ubuntu:14.04')

image.tag('repo' => 'katlean/hatchery-builder', 'tag' => 'latest', force:true)


container = Docker::Container.create(
  'HostConfig' =>  {
    'Privileged' => true
  },
  'Volumes' => {
    "/var/run/docker.sock" => { 'Mountpoint' => '/var/run/docker.sock' }
  },
  
  #### data of github repo to build
  'Env' => [
  'REPOSITORY=remind101/conveyor-builder-test',
  'BRANCH=master',
  'SHA=01ac59b40c069a0114d9aab8bde096527cbab2f8',
  'DRY=true'
  ],
  #'Entrypoint' => ['bash'],
  'Image' => 'katlean/hatchery-builder'
)
#builder would take the data, checout repo, build docker image, push it and exit

container.start

print container.logs(stdout:true, stderr:true)




imageid=container.json['Image'].split(":")[1] ##get the ID of newly built image (should be taken from STDOUT, not fron the builder)

image= Docker::Image.get(imageid)

image.tag('repo' => 'katlean/brand_new_image', 'tag' => '1.0.0', force: true)

image.push




#queue = Queue.new
#queue << builditem
#queue << builditem


#while(!queue.empty?)
#  print "Popped: ", queue.pop
#end

container.delete(:force => true)


