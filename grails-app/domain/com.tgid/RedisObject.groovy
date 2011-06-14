package com.tgid

class RedisObject {

  static mapWith = "redis"

  String name
  //Map<String, Integer> someMap
  List<String> someList

  static mapping = {
    name(index:true)
  }
}
