# frozen_string_literal: true

class Api::V1::CategoriesController < Api::BaseController
  def index
    @categories = Category.all.order(:name)
  end
end
