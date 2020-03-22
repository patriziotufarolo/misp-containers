<?php
class DbConnShell extends AppShell {

        public $uses = array('ConnectionManager');

        public function main() {
                try {
                        $db = ConnectionManager::getDataSource("default");
                        echo $db->isConnected() == true ? 1 : 0;
                } catch (Exception $e) { echo 0; }
                echo "\n";
        }
}
