# frozen_string_literal: true

module Api
  module V1
    class InvestmentTransactionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_investment_transaction, only: %i[show update destroy]

      def index
        @investment_transactions = current_user.investment_transactions.includes(:asset)
        render json: @investment_transactions, include: [:asset]
      end

      def show
        render json: @investment_transaction, include: [:asset]
      end

      def create
        @investment_transaction = current_user.investment_transactions.new(investment_transaction_params)
        if @investment_transaction.save
          render json: @investment_transaction, status: :created
        else
          render json: @investment_transaction.errors, status: :unprocessable_entity
        end
      end

      def update
        if @investment_transaction.update(investment_transaction_params)
          render json: @investment_transaction
        else
          render json: @investment_transaction.errors, status: :unprocessable_entity
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
        params.require(:investment_transaction).permit(:asset_id, :amount, :transaction_type, :date)
      end
    end
  end
end
