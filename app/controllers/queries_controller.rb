# frozen_string_literal: true

class QueriesController < ApplicationController
  before_action :set_query, only: %i[show edit update destroy]

  def index
    @query = Query.new
    @queries = Query.all.limit(5).order('id desc')
  end

  # GET /queries/1
  # GET /queries/1.json
  def show
    @hits = Services::Search.execute(@query)[0..10]
  end

  # GET /queries/new
  def new
    @query = Query.new
  end

  # GET /queries/1/edit
  def edit; end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)

    respond_to do |format|
      if @query.save
        format.html { redirect_to query_path(@query) }
        format.json { render :show, status: :created, location: @query }
      else
        format.html { render :new }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /queries/1
  # PATCH/PUT /queries/1.json
  def update
    respond_to do |format|
      if @query.update(query_params)
        format.html { redirect_to @query, notice: 'Query was successfully updated.' }
        format.json { render :show, status: :ok, location: @query }
      else
        format.html { render :edit }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /queries/1
  # DELETE /queries/1.json
  def destroy
    @query.destroy
    respond_to do |format|
      format.html { redirect_to queries_url, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_query
    @query = Query.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def query_params
    params.require(:query).permit(:value)
  end
end
