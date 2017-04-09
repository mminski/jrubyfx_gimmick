#author: mminski 09.04.2017
require 'jrubyfx'
require 'java'
require 'date'
# require './commons-io-2.5.jar'
require 'jdbc/sqlite3'

# root = File.dirname(__FILE__)
# io = org.apache.commons.io.IOUtils
# pb = java.lang.ProcessBuilder.new(" command ")
# pr = pb.start()
# pr.waitFor()
# puts io.toString(pr.getInputStream)
# puts java.lang.System.getProperty("os.name")
# select url, visit_count from moz_places order by visit_count desc limit 10;


#add path to local firefox places sqlite db
path = 'ADD_PATH_TO_LOCAL_FIREFOX_DB/places.sqlite'

module JavaSql
  include_package 'java.sql'
end

Jdbc::SQLite3.load_driver
Java::org.sqlite.JDBC
$a = []
conn_str = "jdbc:sqlite:#{path}"
conn = JavaSql::DriverManager.getConnection(conn_str)
stm = conn.createStatement
rs = stm.executeQuery('select count(*) as counter from moz_historyvisits, moz_places where datetime(visit_date/1000000,"unixepoch") between datetime("now", "-12 months") and datetime("now", "localtime") and moz_historyvisits.place_id = moz_places.id group by strftime("%m", datetime(visit_date/1000000, "unixepoch"))')
while (rs.next) do
  $a << rs.getString("counter").to_i
end
rs.close
stm.close
conn.close


class BarChart < JRubyFX::Application

  def start(stage)
    @@months = 12.times.collect{|i| date = DateTime.now << i; date.strftime("%B")}.reverse
    @@chart_data = [['Count', $a]]

    with(stage, title: "browsing data", width: 900, height: 700) do
        stage.layout_scene(800, 600) do
              bar_chart(category_axis,
                         number_axis(label: '$ (USD)'),
                         title: 'monthly website visit count') do
                @@chart_data.each_with_index do |(name, chart), j|
                  xy_chart_series(name: name) do
                    @@months.each_with_index do |month, i|
                      xy_chart_data(month, chart[i])
                  end
                end
              end
            end
        end
    end.show

    #event handler : exit on escape key
    stage.scene.set_on_key_released do |event|
      if event.code == KeyCode::ESCAPE
        stage.close()
      end
    end
    # @@textfield.set_on_key_pressed do |event|
    #   if event.code == KeyCode::ENTER
    #     puts @@textfield.text
    #   end
    # end
  end

end
#start jrubyfx app
BarChart.launch
