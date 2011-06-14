package com.tgid

class DataTestController {

  def index = {}

  def getGorm = {
    def gorms = []
    def duration = benchmark {
      def count = GormObject.count()
      (1..Integer.parseInt(params?.recordCount ?: "2")).each {
        gorms << GormObject.findById((Math.random() * count).asType(Integer.class))
      }
    }
    println "Gorm found: ${gorms.size()}"
    render text: duration, contentType: "text/plain"
  }

  def getRedis = {
    def redises = []
    def duration = benchmark {
      def count = RedisObject.count()
      (1..Integer.parseInt(params?.recordCount ?: "2")).each {
        redises << RedisObject.findById((Math.random() * count).asType(Integer.class))
      }
      println "Redis found: ${redises.size()}"
    }
    render text: duration, contentType: "text/plain"
  }

  def makeGorm = {
    Integer total = Integer.parseInt(params?.recordCount ?: "100")
    def duration = benchmark {
      (1..total).each {
        new GormObject(name: "GormObject" + it, someList: makeListData(10)).save()
//        new GormObject(name: "GormObject" + it, someMap: makeMapData(10), someList: makeListData(10)).save()
      }
    }
    render text: duration, contentType: "text/plain"
  }

  def makeRedis = {
    Integer total = Integer.parseInt(params?.recordCount ?: "100")
    def duration = benchmark {
      (1..total).each {
        new RedisObject(name: "RedisObject" + it, someList: makeListData(10)).save()
//        new RedisObject(name: "RedisObject" + it, someMap: makeMapData(10), someList: makeListData(10)).save()
      }
    }
    render text: duration, contentType: "text/plain"
  }

  private makeListData(count) {
    def listData = []
    (1..count).each {
      listData << ["listData${it}"]
    }
    listData
  }

  private makeMapData(count) {
    def mapData = [:]
    (1..count).each {
      mapData << ["mapData${it}": it]
    }
    mapData
  }

  private benchmark = { closure ->
    def start = System.currentTimeMillis()
    closure.call()
    def now = System.currentTimeMillis()
    now - start
  }
}
