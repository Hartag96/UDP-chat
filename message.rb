class Message
  def self.inflate(json)
    attributes = JSON.parse(json)
    new(attributes)
  end

  def initialize(opts = {})
    @nickname = opts['nickname']
    @query = opts['query'] || false
    @content = opts['content']
  end

  def to_json
    { nickname: nickname, query: query, content: content }.to_json
  end
end
