module ArticleHelpers
  def excerpt(article)
    Nokogiri::HTML(article&.body)&.text
      &.split[0..25]
      &.join(' ')
      &.<< '...'
  end
end
