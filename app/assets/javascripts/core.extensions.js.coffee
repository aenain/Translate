Array.prototype.max = () ->
  maxValue = this[0]

  for value in this
    maxValue = value if value > maxValue

  return maxValue