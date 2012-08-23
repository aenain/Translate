class StaticsController < ApplicationController
  def why; end
  def how; end
  def who; end

  def documentation
  	render layout: 'documentation'
  end
end