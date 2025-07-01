# frozen_string_literal: true

class Api::V1::InvestmentTransactionsController < Api::BaseController
  before_action :set_investment_transaction, only: %i[show update destroy]

  def index
    @investment_transactions = current_user.investment_transactions
                                           .includes(:asset, :user)
                                           .order(date: :desc)

    # Filter by asset if provided
    @investment_transactions = @investment_transactions.where(asset_id: params[:asset_id]) if params[:asset_id].present?
  end

  def show; end

  def create
    @investment_transaction = current_user.investment_transactions.build(investment_transaction_params)

    if @investment_transaction.save
      render :show, status: :created
    else
      render json: { errors: @investment_transaction.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @investment_transaction.update(investment_transaction_params)
      render :show
    else
      render json: { errors: @investment_transaction.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @investment_transaction.destroy
    head :no_content
  end

  private

  def set_investment_transaction
    @investment_transaction = current_user.investment_transactions.find(params[:id])
  end

  def investment_transaction_params
    params.require(:investment_transaction).permit(
      :asset_id, :transaction_type, :quantity, :nav,
      :total_amount, :fee, :unit, :date
    )
  end
end
